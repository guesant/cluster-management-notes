const EXTERNAL_ICON = {
	type: 'element',
	tagName: 'svg',
	properties: {
		className: ['nb-link-icon'],
		width: '0.85em',
		height: '0.85em',
		viewBox: '0 0 24 24',
		fill: 'none',
		stroke: 'currentColor',
		strokeWidth: '2',
		strokeLinecap: 'round',
		strokeLinejoin: 'round',
		'aria-hidden': 'true',
		focusable: 'false',
	},
	children: [
		{
			type: 'element',
			tagName: 'path',
			properties: { d: 'M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6' },
			children: [],
		},
		{
			type: 'element',
			tagName: 'path',
			properties: { d: 'M15 3h6v6' },
			children: [],
		},
		{
			type: 'element',
			tagName: 'path',
			properties: { d: 'M10 14 21 3' },
			children: [],
		},
	],
};

function isSameSiteAbsolute(href, siteOrigins) {
	return siteOrigins.some((origin) => href.startsWith(origin));
}

function classifyHref(href, siteOrigins) {
	if (!href || href.startsWith('#')) return null;
	if (href.startsWith('mailto:') || href.startsWith('tel:')) return 'external';
	if (/^([a-z][a-z0-9+.-]*:)?\/\//i.test(href)) {
		return isSameSiteAbsolute(href, siteOrigins) ? 'internal' : 'external';
	}
	return 'internal';
}

function decorate(node, kind) {
	const properties = node.properties ?? (node.properties = {});
	const existingClass = Array.isArray(properties.className) ? properties.className : [];

	if (kind === 'external') {
		properties.className = [...existingClass, 'nb-link', 'nb-link--external'];
		properties.target = '_blank';
		properties.rel = ['noopener', 'noreferrer'];
		node.children = [
			...node.children,
			{ type: 'text', value: ' ' },
			EXTERNAL_ICON,
			{
				type: 'element',
				tagName: 'span',
				properties: { className: ['nb-sr-only'] },
				children: [{ type: 'text', value: ' (abre em nova aba)' }],
			},
		];
	} else {
		properties.className = [...existingClass, 'nb-link', 'nb-link--internal'];
	}
}

function walk(node, siteOrigins) {
	if (node.type === 'element') {
		if (node.tagName === 'a' && typeof node.properties?.href === 'string') {
			const kind = classifyHref(node.properties.href, siteOrigins);
			if (kind) decorate(node, kind);
		}
	}
	for (const child of node.children ?? []) {
		walk(child, siteOrigins);
	}
}

export function rehypeLinkBadges({ siteOrigins = [] } = {}) {
	return (tree) => {
		walk(tree, siteOrigins);
	};
}
