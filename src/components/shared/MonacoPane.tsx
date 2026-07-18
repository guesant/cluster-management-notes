import { useEffect, useRef, useState } from 'react';
import type { ShellEditor } from '../script-helper/monaco-setup';

export function MonacoPane({
	value,
	readOnly,
	onChange,
}: {
	value: string;
	readOnly?: boolean;
	onChange?: (next: string) => void;
}) {
	const hostRef = useRef<HTMLDivElement>(null);
	const editorRef = useRef<ShellEditor | null>(null);
	const [ready, setReady] = useState(false);
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;

	useEffect(() => {
		let disposed = false;
		void (async () => {
			const { createShellEditor } = await import('../script-helper/monaco-setup');
			const host = hostRef.current;
			if (disposed || !host) return;
			const editor = createShellEditor(host, { value, readOnly });
			editor.onDidChangeModelContent(() => onChangeRef.current?.(editor.getValue()));
			editorRef.current = editor;
			setReady(true);
		})();
		return () => {
			disposed = true;
			editorRef.current?.dispose();
			editorRef.current = null;
		};
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	useEffect(() => {
		const editor = editorRef.current;
		if (ready && readOnly && editor && value !== editor.getValue()) {
			editor.setValue(value);
		}
	}, [value, ready, readOnly]);

	return (
		<div className="sh-editor">
			<div ref={hostRef} className="sh-editor-host">
				{!ready && <pre className="sh-editor-fallback">{value}</pre>}
			</div>
		</div>
	);
}
