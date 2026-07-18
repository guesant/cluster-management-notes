import { composeScript, initialFieldStates, maskFieldStates, validateFields } from './compose';
import type { ScriptField } from './types';

export interface PrepareScriptHelperOptions {
	heredoc: boolean;
	strict: boolean;
}

export interface PrepareScriptHelperResult {
	initialOutput: string;
	initialDisplay: string;
}

export function prepareScriptHelper(
	script: string,
	fields: ScriptField[],
	opts: PrepareScriptHelperOptions,
): PrepareScriptHelperResult {
	validateFields(fields);

	const composeOptions = {
		shell: 'bash',
		heredoc: opts.heredoc,
		historyOff: false,
		strict: opts.strict,
		identityPath: '~/.config/age/keys.txt',
	} as const;

	const initialStates = initialFieldStates(fields);
	return {
		initialOutput: composeScript(script, initialStates, composeOptions),
		initialDisplay: composeScript(script, maskFieldStates(initialStates), composeOptions),
	};
}
