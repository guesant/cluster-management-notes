// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';
import react from '@astrojs/react';

// https://astro.build/config
export default defineConfig({
	site: 'https://guesant.github.io',
	base: '/infrastructure-and-cluster-notebook',
	integrations: [
		// astro-mermaid deve vir antes do starlight para interceptar os blocos ```mermaid.
		mermaid({
			theme: 'neutral',
			autoTheme: true,
		}),
		starlight({
			title: 'infrastructure-and-cluster-notebook',
			description:
				'Anotações sobre clusters K3s de nó único ou multinó, com conceitos, melhores práticas, guias passo a passo e scripts.',
			locales: {
				root: { label: 'Português', lang: 'pt-BR' },
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/guesant/infrastructure-and-cluster-notebook',
				},
			],
			editLink: {
				baseUrl: 'https://github.com/guesant/infrastructure-and-cluster-notebook/edit/main/',
			},
			components: {
				Footer: './src/components/overrides/Footer.astro',
			},
			sidebar: [
				{
					label: 'Primeiros passos',
					items: [{ autogenerate: { directory: 'getting-started' } }],
				},
				{
					label: 'Fundamentos',
					items: [{ autogenerate: { directory: 'concepts' } }],
				},
				{
					label: 'Segurança dos hosts',
					items: [{ autogenerate: { directory: 'hosts' } }],
				},
				{
					label: 'Kubernetes',
					items: [
						{ label: 'Workloads', items: [{ autogenerate: { directory: 'kubernetes/workloads' } }] },
						{ label: 'K3s', items: [{ autogenerate: { directory: 'kubernetes/k3s' } }] },
						{ label: 'Rede', items: [{ autogenerate: { directory: 'kubernetes/networking' } }] },
						{
							label: 'Segurança e acesso',
							items: [{ autogenerate: { directory: 'kubernetes/security' } }],
						},
						{ label: 'Extensões', items: [{ autogenerate: { directory: 'kubernetes/extensions' } }] },
					],
				},
				{
					label: 'Guias',
					items: [
						{ label: 'Visão geral de operação', slug: 'guides/operations-overview' },
						{
							label: 'Implantação e atualização',
							items: [{ autogenerate: { directory: 'guides/deployment' } }],
						},
						{ label: 'Gestão de segredos', items: [{ autogenerate: { directory: 'guides/secrets' } }] },
					],
				},
				{
					label: 'Operação',
					items: [{ autogenerate: { directory: 'operations' } }],
				},
				{
					label: 'Referência',
					items: [{ autogenerate: { directory: 'reference' } }],
				},
				{
					label: 'Projeto',
					items: [{ autogenerate: { directory: 'project' } }],
				},
				{
					label: 'Contribuição',
					items: [{ autogenerate: { directory: 'contributing' } }],
				},
			],
		}),
		react(),
	],
});
