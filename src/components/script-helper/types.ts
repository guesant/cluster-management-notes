export type FieldMode = 'read' | 'inline' | 'encrypted';

export interface ScriptField {
	/** Nome da variável bash referenciada pelo corpo do script (ex.: K3S_TOKEN). */
	var: string;
	/** Rótulo do campo na página; também vira o prompt do `read -p`. */
	label: string;
	/** `password` gera `read -s` e aviso de texto claro no modo embutido. */
	type?: 'text' | 'password';
	/** Valor padrão: em modo read vira `VAR="${VAR:-valor}"`; em inline pré-preenche o input. */
	defaultValue?: string;
	placeholder?: string;
	/** Modo inicial do campo; padrão `read`. */
	defaultMode?: FieldMode;
}

/** Estado de um campo no momento da composição do script. */
export interface FieldState {
	field: ScriptField;
	mode: FieldMode;
	value: string;
	/** Ciphertext age em armor ASCII, quando o campo está em modo `encrypted`. */
	ciphertext: string | null;
}

export interface ComposeOptions {
	heredoc: boolean;
	historyOff: boolean;
	strict: boolean;
	/** Caminho da chave privada age na máquina executora (linha `age -d -i`). */
	identityPath: string;
}

/** Configuração serializada do servidor para o script cliente. */
export interface ScriptHelperConfig {
	script: string;
	fields: ScriptField[];
	strict: boolean;
	encryption: boolean;
}
