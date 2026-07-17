import * as React from 'react';
import { cn } from './cn';

const inputClasses =
	'h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm text-foreground placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50';

function Input({ className, ...props }: React.ComponentProps<'input'>) {
	return <input className={cn(inputClasses, className)} {...props} />;
}

function Textarea({ className, ...props }: React.ComponentProps<'textarea'>) {
	return <textarea className={cn(inputClasses, 'h-auto min-h-16 font-mono', className)} {...props} />;
}

function NativeSelect({ className, ...props }: React.ComponentProps<'select'>) {
	return (
		<select
			className={cn(
				'h-9 cursor-pointer rounded-md border border-input bg-background px-2 text-sm text-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none',
				className,
			)}
			{...props}
		/>
	);
}

function Label({ className, ...props }: React.ComponentProps<'label'>) {
	return (
		<label
			className={cn('text-sm leading-none font-medium text-foreground', className)}
			{...props}
		/>
	);
}

function Checkbox({ className, ...props }: React.ComponentProps<'input'>) {
	return (
		<input
			type="checkbox"
			className={cn('size-4 cursor-pointer accent-(--sl-color-accent)', className)}
			{...props}
		/>
	);
}

export { Input, Textarea, NativeSelect, Label, Checkbox };
