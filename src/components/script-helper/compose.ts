// Composição pura do script final: roda no servidor (fallback estático e
// <noscript>) e no navegador (recomposição a cada mudança). Não pode importar
// nada com API de browser.

import type { ComposeOptions, FieldState, ScriptField } from './types';

export const VAR_NAME_RE = /^[A-Za-z_][A-Za-z0-9_]*$/;

/**
 * Caracteres que quebrariam o prompt do `read -p` ou a atribuição de default,
 * ambos emitidos entre aspas duplas.
 */
export const UNSAFE_IN_DOUBLE_QUOTES_RE = /["`$\\]/;

const IDENTITY_PATH_FALLBACK = '~/.config/age/keys.txt';

/** Envolve um valor em aspas simples de shell, escapando `'` como `'\''`. */
export function shellSingleQuote(value: string): string {
	return `'${value.replaceAll("'", "'\\''")}'`;
}

/** Valida os campos declarados via prop; lança erro em tempo de build. */
export function validateFields(fields: ScriptField[]): void {
	const seen = new Set<string>();
	for (const field of fields) {
		if (!VAR_NAME_RE.test(field.var)) {
			throw new Error(`ScriptHelper: nome de variável inválido: "${field.var}"`);
		}
		if (seen.has(field.var)) {
			throw new Error(`ScriptHelper: variável duplicada: "${field.var}"`);
		}
		seen.add(field.var);
		if (UNSAFE_IN_DOUBLE_QUOTES_RE.test(field.label)) {
			throw new Error(
				`ScriptHelper: o label de "${field.var}" não pode conter aspas duplas, crase, cifrão ou barra invertida`,
			);
		}
		if (field.defaultValue && UNSAFE_IN_DOUBLE_QUOTES_RE.test(field.defaultValue)) {
			throw new Error(
				`ScriptHelper: o defaultValue de "${field.var}" não pode conter aspas duplas, crase, cifrão ou barra invertida`,
			);
		}
	}
}

/** Estados iniciais dos campos (modo declarado ou `read`), para o render do servidor. */
export function initialFieldStates(fields: ScriptField[]): FieldState[] {
	return fields.map((field) => ({
		field,
		mode: field.defaultMode ?? 'read',
		value: field.defaultValue ?? '',
		ciphertext: null,
	}));
}

function shellIdentityPath(path: string): string {
	const trimmed = path.trim() || IDENTITY_PATH_FALLBACK;
	if (trimmed.startsWith('~/')) {
		return `"$HOME"${shellSingleQuote(`/${trimmed.slice(2)}`)}`;
	}
	return shellSingleQuote(trimmed);
}

function emitField(state: FieldState, opts: ComposeOptions): string {
	const { field, mode, value, ciphertext } = state;
	const isPassword = field.type === 'password';

	if (mode === 'read') {
		const prompt = field.defaultValue ? `${field.label} [${field.defaultValue}]` : field.label;
		const lines = isPassword
			? [`read -r -s -p "${prompt}: " ${field.var} </dev/tty`, `printf '\\n' >/dev/tty`]
			: [`read -r -p "${prompt}: " ${field.var} </dev/tty`];
		if (field.defaultValue) {
			lines.push(`${field.var}="\${${field.var}:-${field.defaultValue}}"`);
		}
		return lines.join('\n');
	}

	if (mode === 'inline') {
		return `# ${field.label}\n${field.var}=${shellSingleQuote(value)}`;
	}

	if (!ciphertext) {
		return `# ${field.var}: preencha o valor e informe uma chave pública age válida`;
	}
	return [
		`# ${field.label} (decodificado com age na máquina executora)`,
		`${field.var}="$(printf '%s\\n' ${shellSingleQuote(ciphertext)} | age -d -i ${shellIdentityPath(opts.identityPath)})"`,
	].join('\n');
}

/**
 * Escolhe um delimitador de heredoc que não colida com nenhuma linha do
 * conteúdo interno (uma linha igual ao delimitador encerraria o heredoc).
 */
function pickHeredocDelimiter(inner: string): string {
	const lines = new Set(inner.split('\n').map((line) => line.trimEnd()));
	if (!lines.has('EOF')) return 'EOF';
	if (!lines.has('SCRIPT_EOF')) return 'SCRIPT_EOF';
	let n = 2;
	while (lines.has(`SCRIPT_EOF_${n}`)) n += 1;
	return `SCRIPT_EOF_${n}`;
}

/** Aspas simples do fish: dentro delas escapam-se apenas `\` e `'`. */
function fishSingleQuote(value: string): string {
	return `'${value.replaceAll('\\', '\\\\').replaceAll("'", "\\'")}'`;
}

/**
 * Monta o script final. Ordem, de fora para dentro:
 * `set +o history` (opcional, só bash) → encapsulamento por shell →
 * `set -euo pipefail` (opcional) → prólogo por campo → corpo.
 *
 * Encapsulamento: em bash/zsh usa `bash <<'EOF' … EOF` (opcional); o fish não
 * tem heredoc, então o script vai sempre por `printf '%s\n' '…' | bash`. O
 * script em si roda sempre em bash — só o shell interativo de colagem muda.
 * O `set +o history` fica no shell externo para que o comando colado (uma
 * única entrada de histórico) não seja registrado; só existe em bash.
 */
export function composeScript(body: string, states: FieldState[], opts: ComposeOptions): string {
	const blocks: string[] = [];
	if (opts.strict) blocks.push('set -euo pipefail');
	for (const state of states) blocks.push(emitField(state, opts));
	const trimmedBody = body.replace(/^\n+/, '').replace(/\s+$/, '');
	if (trimmedBody) blocks.push(trimmedBody);
	const inner = blocks.join('\n\n');

	let out = inner;
	if (opts.shell === 'fish') {
		out = `printf '%s\\n' ${fishSingleQuote(inner)} | bash`;
	} else if (opts.heredoc) {
		const delimiter = pickHeredocDelimiter(inner);
		out = `bash <<'${delimiter}'\n${inner}\n${delimiter}`;
	}
	if (opts.historyOff && opts.shell === 'bash') {
		out = `set +o history\n${out}\nset -o history`;
	}
	return `${out}\n`;
}
