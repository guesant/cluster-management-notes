import { useEffect, useRef, useState } from 'react';
import { Icon } from '@iconify/react';
import copyIcon from '@iconify-icons/lucide/copy';
import checkIcon from '@iconify-icons/lucide/check';
import { clsx } from 'clsx';
import { Button } from '../script-helper/ui/button';
import { MonacoPane } from '../shared/MonacoPane';
import ScriptHelperApp, { RunBanner, type ScriptHelperAppProps } from '../script-helper/ScriptHelperApp';
import '../script-helper/styles.css';
import 'monaco-editor/min/vs/style.css';

type Tab = 'content' | 'script';
type Editor = 'vim' | 'nvim' | 'nano';

const EDITORS: Editor[] = ['vim', 'nvim', 'nano'];

function CopyButton({ text, label }: { text: string; label: string }) {
	const [copied, setCopied] = useState(false);
	const timerRef = useRef<number | undefined>(undefined);

	async function handleCopy() {
		await navigator.clipboard.writeText(text);
		setCopied(true);
		window.clearTimeout(timerRef.current);
		timerRef.current = window.setTimeout(() => setCopied(false), 2000);
	}

	useEffect(() => () => window.clearTimeout(timerRef.current), []);

	return (
		<Button size="sm" variant="outline" onClick={handleCopy}>
			<Icon icon={copied ? checkIcon : copyIcon} className="sh-icon" aria-hidden />
			{copied ? 'Copiado!' : label}
		</Button>
	);
}

export interface FileWriterAppProps {
	path: string;
	dir: string;
	owner: string;
	group: string;
	content: string;
	script: string;
	fields: ScriptHelperAppProps['fields'];
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

export default function FileWriterApp(props: FileWriterAppProps) {
	const [tab, setTab] = useState<Tab>('script');
	const [editor, setEditor] = useState<Editor>('vim');

	const editCommand = `${editor} ${props.path}`;
	const mkdirCommand = `mkdir -p ${props.dir}`;
	const chownCommand = `chown ${props.owner}:${props.group} ${props.dir}`;

	return (
		<div className="fw-root">
			<RunBanner user={props.runUser} where={props.runWhere} />
			<div className="sh-toolbar">
				<p className="sh-toolbar-title">Criar o arquivo</p>
				<div role="tablist" aria-label="Como criar o arquivo" className="sh-tabs">
					{(
						[
							['content', 'Conteúdo'],
							['script', 'Script'],
						] as const
					).map(([value, label]) => (
						<button
							key={value}
							type="button"
							role="tab"
							aria-selected={tab === value}
							onClick={() => setTab(value)}
							className={clsx('sh-tab', tab === value && 'sh-tab--active')}
						>
							{label}
						</button>
					))}
				</div>
			</div>

			{tab === 'content' ? (
				<div className="fw-content">
					<div className="fw-row">
						<div className="fw-field">
							<p className="sh-note">Criar o diretório e o dono</p>
							<div className="fw-row">
								<code className="fw-path">{mkdirCommand}</code>
								<CopyButton text={mkdirCommand} label="Copiar mkdir" />
							</div>
							<div className="fw-row">
								<code className="fw-path">{chownCommand}</code>
								<CopyButton text={chownCommand} label="Copiar chown" />
							</div>
						</div>
						<div className="fw-field">
							<p className="sh-note">Caminho de destino</p>
							<div className="fw-row">
								<code className="fw-path">{props.path}</code>
								<CopyButton text={props.path} label="Copiar caminho" />
							</div>
						</div>
						<div className="fw-field">
							<p className="sh-note">Editor</p>
							<div className="fw-row">
								<div role="tablist" aria-label="Editor de texto" className="sh-tabs">
									{EDITORS.map((name) => (
										<button
											key={name}
											type="button"
											role="tab"
											aria-selected={editor === name}
											onClick={() => setEditor(name)}
											className={clsx('sh-tab', editor === name && 'sh-tab--active')}
										>
											{name}
										</button>
									))}
								</div>
								<code className="fw-path">{editCommand}</code>
								<CopyButton text={editCommand} label="Copiar comando" />
							</div>
						</div>
					</div>

					<MonacoPane value={props.content} readOnly />

					<p className="sh-note">
						Abra o arquivo com o comando acima, cole o conteúdo abaixo e substitua cada{' '}
						<code>${'{VAR}'}</code> pelo valor correspondente antes de salvar.
					</p>
					<CopyButton text={props.content} label="Copiar conteúdo" />
				</div>
			) : (
				<ScriptHelperApp
					script={props.script}
					fields={props.fields}
					title={props.title}
					heredoc={props.heredoc}
					historyToggle={props.historyToggle}
					encryption={props.encryption}
					strict={props.strict}
					initialOutput={props.initialOutput}
					initialDisplay={props.initialDisplay}
				/>
			)}
		</div>
	);
}
