import * as React from 'react';
import * as DialogPrimitive from '@radix-ui/react-dialog';
import { Icon } from '@iconify/react';
import xIcon from '@iconify-icons/lucide/x';
import { cn } from './cn';

const Dialog = DialogPrimitive.Root;
const DialogTrigger = DialogPrimitive.Trigger;
const DialogClose = DialogPrimitive.Close;

function DialogContent({
	className,
	children,
	...props
}: React.ComponentProps<typeof DialogPrimitive.Content>) {
	return (
		<DialogPrimitive.Portal>
			<DialogPrimitive.Overlay className="fixed inset-0 z-50 bg-black/60" />
			<DialogPrimitive.Content
				className={cn(
					'fixed top-1/2 left-1/2 z-50 grid max-h-[85vh] w-[calc(100vw-2rem)] max-w-2xl -translate-x-1/2 -translate-y-1/2 gap-4 overflow-y-auto rounded-lg border border-border bg-card p-6 text-card-foreground shadow-xl',
					className,
				)}
				{...props}
			>
				{children}
				<DialogPrimitive.Close
					className="absolute top-4 right-4 cursor-pointer rounded-sm text-muted-foreground opacity-70 transition-opacity hover:opacity-100 focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
					aria-label="Fechar"
				>
					<Icon icon={xIcon} className="size-4" />
				</DialogPrimitive.Close>
			</DialogPrimitive.Content>
		</DialogPrimitive.Portal>
	);
}

function DialogHeader({ className, ...props }: React.ComponentProps<'div'>) {
	return <div className={cn('flex flex-col gap-1.5', className)} {...props} />;
}

function DialogFooter({ className, ...props }: React.ComponentProps<'div'>) {
	return <div className={cn('flex justify-end gap-2', className)} {...props} />;
}

function DialogTitle({ className, ...props }: React.ComponentProps<typeof DialogPrimitive.Title>) {
	return (
		<DialogPrimitive.Title
			className={cn('m-0 text-base leading-none font-semibold', className)}
			{...props}
		/>
	);
}

function DialogDescription({
	className,
	...props
}: React.ComponentProps<typeof DialogPrimitive.Description>) {
	return (
		<DialogPrimitive.Description
			className={cn('m-0 text-sm text-muted-foreground', className)}
			{...props}
		/>
	);
}

export {
	Dialog,
	DialogTrigger,
	DialogClose,
	DialogContent,
	DialogHeader,
	DialogFooter,
	DialogTitle,
	DialogDescription,
};
