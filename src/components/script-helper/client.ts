// Wiring de DOM + CodeMirror do ScriptHelper. Roda apenas no navegador.
// Tudo acontece localmente: nenhum valor preenchido sai da página.

import { EditorState } from '@codemirror/state';
import { EditorView, lineNumbers } from '@codemirror/view';
import { minimalSetup } from 'codemirror';
import { HighlightStyle, StreamLanguage, syntaxHighlighting } from '@codemirror/language';
import { shell } from '@codemirror/legacy-modes/mode/shell';
import { tags } from '@lezer/highlight';
import { composeScript } from './compose';
import type { FieldMode, FieldState, ScriptHelperConfig } from './types';
import { encryptValue, isLikelyAgeRecipient } from './encryption';

const IDENTITY_PATH_DEFAULT = '~/.config/age/keys.txt';

const MESSAGES = {
	inlinePassword:
		'Atenção: o valor ficará em texto claro no script gerado. Considere o modo criptografado ou desativar o histórico do bash.',
	encrypted:
		'Requer o CLI `age` e a chave privada correspondente na máquina que executará o script.',
	invalidRecipient: 'Chave pública age inválida (use o valor age1… gerado por age-keygen).',
	missingRecipient: 'Informe a chave pública age (age1…) para criptografar os campos marcados.',
	copied: 'Copiado!',
	copyFailed: 'Falha ao copiar — selecione o texto manualmente.',
};

const shellLanguage = StreamLanguage.define(shell);

// As cores vêm de variáveis CSS definidas em ScriptHelper.astro (mapeadas nos
// tokens do Starlight), então o tema claro/escuro resolve sem JavaScript.
const highlight = HighlightStyle.define([
	{ tag: tags.keyword, color: 'var(--sh-cm-keyword)' },
	{ tag: tags.atom, color: 'var(--sh-cm-atom)' },
	{ tag: tags.number, color: 'var(--sh-cm-atom)' },
	{ tag: tags.string, color: 'var(--sh-cm-string)' },
	{ tag: tags.special(tags.string), color: 'var(--sh-cm-string-special)' },
	{ tag: tags.comment, color: 'var(--sh-cm-comment)', fontStyle: 'italic' },
	{ tag: tags.variableName, color: 'var(--sh-cm-variable)' },
	{ tag: tags.definition(tags.variableName), color: 'var(--sh-cm-variable)' },
	{ tag: tags.standard(tags.variableName), color: 'var(--sh-cm-builtin)' },
	{ tag: tags.meta, color: 'var(--sh-cm-comment)' },
]);

const theme = EditorView.theme({
	'&': {
		backgroundColor: 'var(--sh-cm-bg)',
		color: 'var(--sh-cm-text)',
		border: '1px solid var(--sl-color-gray-5)',
		borderRadius: '0.25rem',
		fontSize: 'var(--sl-text-sm)',
	},
	'.cm-scroller': {
		fontFamily: 'var(--sl-font-system-mono, ui-monospace, monospace)',
		lineHeight: '1.6',
		maxHeight: '28rem',
	},
	'.cm-content': { caretColor: 'var(--sh-cm-text)' },
	'.cm-gutters': {
		backgroundColor: 'var(--sh-cm-bg)',
		color: 'var(--sl-color-gray-3)',
		border: 'none',
	},
	'&.cm-focused': { outline: '2px solid var(--sl-color-accent)' },
});

const baseExtensions = [
	minimalSetup,
	lineNumbers(),
	shellLanguage,
	syntaxHighlighting(highlight),
	theme,
	EditorView.lineWrapping,
];

function debounce(fn: () => void, ms: number) {
	let timer: number | undefined;
	return () => {
		window.clearTimeout(timer);
		timer = window.setTimeout(fn, ms);
	};
}

interface FieldControls {
	varName: string;
	input: HTMLInputElement;
	modeSelect: HTMLSelectElement;
	warning: HTMLElement;
}

function initScriptHelper(root: HTMLElement) {
	const configEl = root.querySelector<HTMLElement>('[data-config]');
	if (!configEl?.textContent) return;
	const config = JSON.parse(configEl.textContent) as ScriptHelperConfig;

	const editorHost = root.querySelector<HTMLElement>('[data-editor]')!;
	const outputHost = root.querySelector<HTMLElement>('[data-output-editor]')!;
	const outputFallback = root.querySelector<HTMLElement>('[data-output-fallback]')!;
	const heredocToggle = root.querySelector<HTMLInputElement>('[data-toggle-heredoc]')!;
	const historyToggle = root.querySelector<HTMLInputElement>('[data-toggle-history]');
	const copyButton = root.querySelector<HTMLButtonElement>('[data-copy]')!;
	const copyStatus = root.querySelector<HTMLElement>('[data-copy-status]')!;
	const cryptoBox = root.querySelector<HTMLElement>('[data-crypto-box]');
	const recipientInput = root.querySelector<HTMLTextAreaElement>('[data-recipient]');
	const recipientStatus = root.querySelector<HTMLElement>('[data-recipient-status]');
	const identityInput = root.querySelector<HTMLInputElement>('[data-identity]');

	const fields: FieldControls[] = [];
	for (const fieldEl of root.querySelectorAll<HTMLElement>('[data-field]')) {
		fields.push({
			varName: fieldEl.dataset.field!,
			input: fieldEl.querySelector<HTMLInputElement>('[data-field-input]')!,
			modeSelect: fieldEl.querySelector<HTMLSelectElement>('[data-field-mode]')!,
			warning: fieldEl.querySelector<HTMLElement>('[data-warning]')!,
		});
	}
	const fieldByVar = new Map(config.fields.map((f) => [f.var, f]));

	const bodyView = new EditorView({
		state: EditorState.create({
			doc: config.script,
			extensions: [
				...baseExtensions,
				EditorView.updateListener.of((update) => {
					if (update.docChanged) scheduleRecompose();
				}),
			],
		}),
		parent: editorHost,
	});

	const outputView = new EditorView({
		state: EditorState.create({
			doc: '',
			extensions: [...baseExtensions, EditorState.readOnly.of(true), EditorView.editable.of(false)],
		}),
		parent: outputHost,
	});

	outputFallback.hidden = true;

	function applyFieldMode(control: FieldControls) {
		const mode = control.modeSelect.value as FieldMode;
		const field = fieldByVar.get(control.varName);
		control.input.disabled = mode === 'read';

		if (mode === 'inline' && field?.type === 'password') {
			control.warning.textContent = MESSAGES.inlinePassword;
			control.warning.hidden = false;
		} else if (mode === 'encrypted') {
			control.warning.textContent = MESSAGES.encrypted;
			control.warning.hidden = false;
		} else {
			control.warning.hidden = true;
		}

		if (cryptoBox) {
			cryptoBox.hidden = !fields.some((c) => c.modeSelect.value === 'encrypted');
		}
	}

	let recomposeToken = 0;
	async function recompose() {
		const token = ++recomposeToken;
		const recipient = recipientInput?.value.trim() ?? '';
		let recipientError: string | null = null;

		const states: FieldState[] = [];
		for (const control of fields) {
			const field = fieldByVar.get(control.varName);
			if (!field) continue;
			const mode = control.modeSelect.value as FieldMode;
			const value = control.input.value;
			let ciphertext: string | null = null;

			if (mode === 'encrypted' && value) {
				if (!recipient) {
					recipientError = MESSAGES.missingRecipient;
				} else if (!isLikelyAgeRecipient(recipient)) {
					recipientError = MESSAGES.invalidRecipient;
				} else {
					try {
						ciphertext = await encryptValue(value, recipient);
					} catch {
						recipientError = MESSAGES.invalidRecipient;
					}
				}
			}
			states.push({ field, mode, value, ciphertext });
		}

		// Uma recomposição mais nova foi agendada enquanto a criptografia rodava.
		if (token !== recomposeToken) return;

		if (recipientStatus) {
			recipientStatus.textContent = recipientError ?? '';
			recipientStatus.hidden = !recipientError;
		}

		const output = composeScript(bodyView.state.doc.toString(), states, {
			heredoc: heredocToggle.checked,
			historyOff: historyToggle?.checked ?? false,
			strict: config.strict,
			identityPath: identityInput?.value ?? IDENTITY_PATH_DEFAULT,
		});
		outputView.dispatch({
			changes: { from: 0, to: outputView.state.doc.length, insert: output },
		});
	}

	const scheduleRecompose = debounce(() => void recompose(), 150);

	for (const control of fields) {
		control.input.addEventListener('input', scheduleRecompose);
		control.modeSelect.addEventListener('change', () => {
			applyFieldMode(control);
			scheduleRecompose();
		});
		applyFieldMode(control);
	}
	for (const el of [heredocToggle, historyToggle, recipientInput, identityInput]) {
		el?.addEventListener('input', scheduleRecompose);
		el?.addEventListener('change', scheduleRecompose);
	}

	let copyResetTimer: number | undefined;
	copyButton.addEventListener('click', async () => {
		const text = outputView.state.doc.toString();
		let ok = true;
		try {
			await navigator.clipboard.writeText(text);
		} catch {
			ok = legacyCopy(text);
		}
		copyStatus.textContent = ok ? MESSAGES.copied : MESSAGES.copyFailed;
		window.clearTimeout(copyResetTimer);
		copyResetTimer = window.setTimeout(() => {
			copyStatus.textContent = '';
		}, 2000);
	});

	void recompose();
}

function legacyCopy(text: string): boolean {
	const textarea = document.createElement('textarea');
	textarea.value = text;
	textarea.setAttribute('readonly', '');
	textarea.style.position = 'fixed';
	textarea.style.opacity = '0';
	document.body.append(textarea);
	textarea.select();
	let ok = false;
	try {
		ok = document.execCommand('copy');
	} catch {
		ok = false;
	}
	textarea.remove();
	return ok;
}

export function initScriptHelpers() {
	for (const root of document.querySelectorAll<HTMLElement>('[data-script-helper]')) {
		initScriptHelper(root);
	}
}
