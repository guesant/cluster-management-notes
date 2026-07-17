import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from './cn';

const buttonVariants = cva(
	'inline-flex cursor-pointer items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-colors focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50',
	{
		variants: {
			variant: {
				default: 'bg-primary text-primary-foreground hover:opacity-90',
				outline:
					'border border-border bg-background text-foreground hover:bg-accent hover:text-accent-foreground',
				ghost: 'text-foreground hover:bg-accent hover:text-accent-foreground',
			},
			size: {
				default: 'h-9 px-4 py-2',
				sm: 'h-8 px-3 text-xs',
				icon: 'size-9',
			},
		},
		defaultVariants: { variant: 'default', size: 'default' },
	},
);

function Button({
	className,
	variant,
	size,
	...props
}: React.ComponentProps<'button'> & VariantProps<typeof buttonVariants>) {
	return (
		<button type="button" className={cn(buttonVariants({ variant, size }), className)} {...props} />
	);
}

export { Button, buttonVariants };
