import { useEffect, useRef, useState } from 'react';
import { Icon } from '@iconify/react';
import settingsIcon from '@iconify-icons/lucide/settings';
import copyIcon from '@iconify-icons/lucide/copy';
import checkIcon from '@iconify-icons/lucide/check';
import terminalIcon from '@iconify-icons/lucide/terminal';
import { composeScript, generatedSecretPath, maskFieldStates } from './compose';
import type { FieldMode, FieldState, ScriptField, TargetShell } from './types';
import { clsx } from 'clsx';
import { encryptValue, isLikelyAgeRecipient } from './encryption';
import { Button } from './ui/button';
import {
	Dialog,
	DialogClose,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from './ui/dialog';
import { Checkbox, Input, Label, NativeSelect, Textarea } from './ui/fields';
import { MonacoPane } from '../shared/MonacoPane';
import 'monaco-editor/min/vs/style.css';
import './styles.css';

const IDENTITY_PATH_DEFAULT = '~/.config/age/keys.txt';

const MESSAGES = {
	inlinePassword:
		'O preview acima mostra *** no lugar do valor, mas o script copiado o contém em texto claro. Considere o modo criptografado ou desativar o histórico do bash.',
	generate:
		'O valor é criado na hora da execução com openssl rand; nem esta página nem o script copiado o contêm.',
	encrypted: 'Requer o CLI age e a chave privada correspondente na máquina que executará o script.',
	invalidRecipient: 'Chave pública age inválida (use o valor age1… gerado por age-keygen).',
	missingRecipient: 'Informe a chave pública age (age1…) para criptografar os campos marcados.',
};

const MODE_LABELS: Record<FieldMode, string> = {
	read: 'Perguntar ao executar (read)',
	inline: 'Embutir no script',
	encrypted: 'Criptografar (age)',
	generate: 'Gerar ao executar (openssl rand)',
};

export interface ScriptHelperAppProps {
	script: string;
	fields: ScriptField[];
	title?: string;
	heredoc: boolean;
	historyToggle: boolean;
	encryption: boolean;
	strict: boolean;
	runUser?: string;
	runWhere?: string;
	initialOutput: string;
	initialDisplay: string;
}

export function RunBanner({ user, where }: { user?: string; where?: string }) {
	if (!user && !where) return null;
	return (
		<div className="sh-run-banner">
			<Icon icon={terminalIcon} className="sh-icon" aria-hidden />
			<p>
				{user && (
					<>
						Execute como <code>{user}</code>
					</>
				)}
				{user && where && ' em: '}
				{!user && where && 'Executar em: '}
				{where}
			</p>
		</div>
	);
}

export default function ScriptHelperApp(props: ScriptHelperAppProps) {
	const [body, setBody] = useState(props.script);
	const [values, setValues] = useState<Record<string, string>>(() =>
		Object.fromEntries(props.fields.map((f) => [f.var, f.defaultValue ?? ''])),
	);
	const [modes, setModes] = useState<Record<string, FieldMode>>(() =>
		Object.fromEntries(props.fields.map((f) => [f.var, f.defaultMode ?? 'read'])),
	);
	const [shell, setShell] = useState<TargetShell>('bash');
	const [heredoc, setHeredoc] = useState(props.heredoc);
	const [historyOff, setHistoryOff] = useState(false);
	const [recipient, setRecipient] = useState('');
	const [identityPath, setIdentityPath] = useState(IDENTITY_PATH_DEFAULT);
	const [saves, setSaves] = useState<Record<string, boolean>>({});
	const [output, setOutput] = useState(props.initialOutput);
	const [display, setDisplay] = useState(props.initialDisplay);
	const [recipientError, setRecipientError] = useState<string | null>(null);
	const [copied, setCopied] = useState(false);

	const outputRef = useRef(output);
	outputRef.current = output;

	const tokenRef = useRef(0);
	useEffect(() => {
		const token = ++tokenRef.current;
		const timer = window.setTimeout(async () => {
			let error: string | null = null;
			const states: FieldState[] = [];
			for (const field of props.fields) {
				const mode = modes[field.var] ?? 'read';
				const value = values[field.var] ?? '';
				let ciphertext: string | null = null;
				if (mode === 'encrypted' && value) {
					const trimmed = recipient.trim();
					if (!trimmed) {
						error = MESSAGES.missingRecipient;
					} else if (!isLikelyAgeRecipient(trimmed)) {
						error = MESSAGES.invalidRecipient;
					} else {
						try {
							ciphertext = await encryptValue(value, trimmed);
						} catch {
							error = MESSAGES.invalidRecipient;
						}
					}
				}
				states.push({ field, mode, value, ciphertext, saveGenerated: saves[field.var] ?? false });
			}
			if (token !== tokenRef.current) return;
			setRecipientError(error);
			const opts = {
				shell,
				heredoc,
				historyOff,
				strict: props.strict,
				identityPath,
			};
			setOutput(composeScript(body, states, opts));
			setDisplay(composeScript(body, maskFieldStates(states), opts));
		}, 150);
		return () => window.clearTimeout(timer);
	}, [
		body,
		values,
		modes,
		saves,
		shell,
		heredoc,
		historyOff,
		recipient,
		identityPath,
		props.fields,
		props.strict,
	]);

	const copyButtonRef = useRef<HTMLButtonElement>(null);
	useEffect(() => {
		const button = copyButtonRef.current;
		if (!button) return;
		let clip: { destroy: () => void } | null = null;
		let timer: number | undefined;
		let disposed = false;
		void (async () => {
			const { default: ClipboardJS } = await import('clipboard');
			if (disposed) return;
			const instance = new ClipboardJS(button, { text: () => outputRef.current });
			instance.on('success', () => {
				setCopied(true);
				window.clearTimeout(timer);
				timer = window.setTimeout(() => setCopied(false), 2000);
			});
			clip = instance;
		})();
		return () => {
			disposed = true;
			clip?.destroy();
			window.clearTimeout(timer);
		};
	}, []);

	const anyEncrypted = props.fields.some((f) => (modes[f.var] ?? 'read') === 'encrypted');

	return (
		<div className="sh-root">
			<RunBanner user={props.runUser} where={props.runWhere} />
			<div className="sh-toolbar">
				<p className="sh-toolbar-title">
					{props.title ?? 'Script final (copie este)'}
				</p>
				<div
					role="tablist"
					aria-label="Shell do terminal onde o comando será colado"
					className="sh-tabs"
				>
					{(['bash', 'zsh', 'fish'] as const).map((s) => (
						<button
							key={s}
							type="button"
							role="tab"
							aria-selected={shell === s}
							onClick={() => setShell(s)}
							className={clsx('sh-tab', shell === s && 'sh-tab--active')}
						>
							{s}
						</button>
					))}
				</div>
				<Dialog>
					<DialogTrigger asChild>
						<Button variant="outline" size="sm">
							<Icon icon={settingsIcon} className="sh-icon" aria-hidden />
							Personalizar
						</Button>
					</DialogTrigger>
					<DialogContent>
						<DialogHeader>
							<DialogTitle>Personalizar script</DialogTitle>
							<DialogDescription>
								Os valores preenchidos ficam só no seu navegador — nada é enviado para fora desta
								página.
							</DialogDescription>
						</DialogHeader>

						{props.fields.length > 0 && (
							<div className="sh-fields">
								{props.fields.map((field) => {
									const mode = modes[field.var] ?? 'read';
									const warning =
										mode === 'inline' && field.type === 'password'
											? MESSAGES.inlinePassword
											: mode === 'encrypted'
												? MESSAGES.encrypted
												: mode === 'generate'
													? MESSAGES.generate
													: null;
									return (
										<div key={field.var} className="sh-field">
											<Label htmlFor={`sh-input-${field.var}`}>
												{field.label}{' '}
												<code className="sh-field-var">${field.var}</code>
											</Label>
											<div className="sh-field-row">
												<Input
													id={`sh-input-${field.var}`}
													type={field.type === 'password' ? 'password' : 'text'}
													className="sh-field-input"
													placeholder={field.placeholder ?? ''}
													value={values[field.var] ?? ''}
													disabled={mode === 'read' || mode === 'generate'}
													onChange={(e) =>
														setValues((prev) => ({ ...prev, [field.var]: e.target.value }))
													}
												/>
												<NativeSelect
													aria-label={`Modo do campo ${field.label}`}
													value={mode}
													onChange={(e) =>
														setModes((prev) => ({
															...prev,
															[field.var]: e.target.value as FieldMode,
														}))
													}
												>
													<option value="read">{MODE_LABELS.read}</option>
													<option value="inline">{MODE_LABELS.inline}</option>
													{props.encryption && (
														<option value="encrypted">{MODE_LABELS.encrypted}</option>
													)}
													{field.type === 'password' && (
														<option value="generate">{MODE_LABELS.generate}</option>
													)}
												</NativeSelect>
											</div>
											{mode === 'generate' && (
												<Label className="sh-toggle">
													<Checkbox
														checked={saves[field.var] ?? false}
														onChange={(e) =>
															setSaves((prev) => ({ ...prev, [field.var]: e.target.checked }))
														}
													/>
													Salvar o valor gerado em <code>{generatedSecretPath(field.var)}</code>
												</Label>
											)}
											{warning && <p className="sh-note sh-note--warning">{warning}</p>}
										</div>
									);
								})}
							</div>
						)}

						{props.encryption && anyEncrypted && (
							<div className="sh-encryption-box">
								<div className="sh-field">
									<Label htmlFor="sh-recipient">Chave pública age (recipient)</Label>
									<Textarea
										id="sh-recipient"
										rows={2}
										placeholder="age1..."
										value={recipient}
										onChange={(e) => setRecipient(e.target.value)}
									/>
								</div>
								<div className="sh-field">
									<Label htmlFor="sh-identity">Caminho da chave privada na máquina executora</Label>
									<Input
										id="sh-identity"
										value={identityPath}
										onChange={(e) => setIdentityPath(e.target.value)}
									/>
								</div>
								<p className="sh-note">
									Gere um par de chaves com <code>age-keygen -o ~/.config/age/keys.txt</code> e cole
									aqui a chave pública (<code>age1…</code>). A criptografia acontece no seu
									navegador; para decodificar, a máquina que executa o script precisa do CLI{' '}
									<code>age</code> e da chave privada correspondente.
								</p>
								{recipientError && <p className="sh-note sh-note--error">{recipientError}</p>}
							</div>
						)}

						<div className="sh-field">
							<div className="sh-toggles">
								<Label className={clsx('sh-toggle', shell === 'fish' && 'sh-toggle--disabled')}>
									<Checkbox
										checked={shell === 'fish' ? true : heredoc}
										disabled={shell === 'fish'}
										onChange={(e) => setHeredoc(e.target.checked)}
									/>
									Envolver em <code>bash &lt;&lt;'EOF'</code>
								</Label>
								{props.historyToggle && (
									<Label className={clsx('sh-toggle', shell !== 'bash' && 'sh-toggle--disabled')}>
										<Checkbox
											checked={shell === 'bash' && historyOff}
											disabled={shell !== 'bash'}
											onChange={(e) => setHistoryOff(e.target.checked)}
										/>
										Desativar histórico do bash
									</Label>
								)}
							</div>
							{shell === 'fish' && (
								<p className="sh-note">
									No fish não há heredoc: o script é sempre encapsulado com{' '}
									<code>printf … | bash</code>. Desativar o histórico só está disponível no bash.
								</p>
							)}
						</div>

						<details className="sh-advanced">
							<summary>Editar corpo do script (avançado)</summary>
							<div className="sh-advanced-body">
								<MonacoPane value={body} onChange={setBody} />
							</div>
						</details>

						<DialogFooter>
							<DialogClose asChild>
								<Button variant="outline">Concluído</Button>
							</DialogClose>
						</DialogFooter>
					</DialogContent>
				</Dialog>
				<Button size="sm" ref={copyButtonRef}>
					<Icon icon={copied ? checkIcon : copyIcon} className="sh-icon" aria-hidden />
					{copied ? 'Copiado!' : 'Copiar script'}
				</Button>
				<span className="sh-sr-only" aria-live="polite">
					{copied ? 'Script copiado' : ''}
				</span>
			</div>

			<MonacoPane value={display} readOnly />

			<p className="sh-note">
				Os valores preenchidos ficam só no seu navegador — nada é enviado para fora desta página.
				Leia o script gerado por completo antes de executá-lo.
			</p>
		</div>
	);
}
