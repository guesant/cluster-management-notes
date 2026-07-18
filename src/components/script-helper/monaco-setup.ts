import * as monaco from 'monaco-editor/esm/vs/editor/editor.api';
import 'monaco-editor/esm/vs/basic-languages/shell/shell.contribution';
// @ts-expect-error
import EditorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker';

export type ShellEditor = monaco.editor.IStandaloneCodeEditor;

const THEME_NAME = 'script-helper';
let ready = false;

function resolveColor(cssVar: string, fallback: string): string {
	const probe = document.createElement('span');
	probe.style.cssText = `position:absolute;visibility:hidden;color:var(${cssVar})`;
	document.body.append(probe);
	const rgb = getComputedStyle(probe).color.match(/\d+/g);
	probe.remove();
	if (!rgb || rgb.length < 3) return fallback;
	return `#${rgb
		.slice(0, 3)
		.map((n) => Number(n).toString(16).padStart(2, '0'))
		.join('')}`;
}

function applyTheme() {
	const dark = document.documentElement.dataset.theme !== 'light';
	monaco.editor.defineTheme(THEME_NAME, {
		base: dark ? 'vs-dark' : 'vs',
		inherit: true,
		rules: [],
		colors: {
			'editor.background': resolveColor('--sl-color-black', dark ? '#17181c' : '#ffffff'),
			'editor.foreground': resolveColor('--sl-color-white', dark ? '#ffffff' : '#17181c'),
		},
	});
	monaco.editor.setTheme(THEME_NAME);
}

function ensureSetup() {
	if (ready) return;
	ready = true;
	(self as { MonacoEnvironment?: unknown }).MonacoEnvironment = {
		getWorker: () => new EditorWorker(),
	};
	applyTheme();
	new MutationObserver(applyTheme).observe(document.documentElement, {
		attributes: true,
		attributeFilter: ['data-theme'],
	});
}

const baseEditorOptions: monaco.editor.IStandaloneEditorConstructionOptions = {
	language: 'shell',
	theme: THEME_NAME,
	minimap: { enabled: false },
	wordWrap: 'on',
	wrappingStrategy: 'advanced',
	scrollBeyondLastLine: false,
	automaticLayout: true,
	folding: false,
	fontSize: 13,
	lineNumbersMinChars: 3,
	padding: { top: 8, bottom: 8 },
	scrollbar: { alwaysConsumeMouseWheel: false },
	overviewRulerLanes: 0,
	contextmenu: false,
};

function autoGrow(editor: ShellEditor, host: HTMLElement, maxPx = 460) {
	const apply = () => {
		const height = Math.min(Math.max(editor.getContentHeight(), 96), maxPx);
		host.style.height = `${height}px`;
		editor.layout();
	};
	editor.onDidContentSizeChange(apply);
	apply();
}

export function createShellEditor(
	host: HTMLElement,
	opts: { value: string; readOnly?: boolean },
): ShellEditor {
	ensureSetup();
	const editor = monaco.editor.create(host, {
		...baseEditorOptions,
		value: opts.value,
		...(opts.readOnly
			? { readOnly: true, domReadOnly: true, renderLineHighlight: 'none' as const }
			: {}),
	});
	autoGrow(editor, host);
	requestAnimationFrame(() => editor.layout());
	return editor;
}
