export type FieldMode = 'read' | 'inline' | 'encrypted' | 'generate';

export type TargetShell = 'bash' | 'zsh' | 'fish';

export interface ScriptField {
	var: string;
	label: string;
	type?: 'text' | 'password';
	defaultValue?: string;
	placeholder?: string;
	defaultMode?: FieldMode;
}

export interface FieldState {
	field: ScriptField;
	mode: FieldMode;
	value: string;
	ciphertext: string | null;
	saveGenerated: boolean;
}

export interface ComposeOptions {
	shell: TargetShell;
	heredoc: boolean;
	historyOff: boolean;
	strict: boolean;
	identityPath: string;
}

export interface ScriptHelperConfig {
	script: string;
	fields: ScriptField[];
	strict: boolean;
	encryption: boolean;
}
