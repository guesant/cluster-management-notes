import * as mdx from 'eslint-plugin-mdx';

export default [
	{
		...mdx.flat,
		files: ['src/content/docs/**/*.mdx'],
	},
	{
		...mdx.flatCodeBlocks,
		files: ['src/content/docs/**/*.mdx'],
	},
];
