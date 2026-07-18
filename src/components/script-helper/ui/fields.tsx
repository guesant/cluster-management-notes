import * as React from 'react';
import { clsx } from 'clsx';

function Input({ className, ...props }: React.ComponentProps<'input'>) {
	return <input className={clsx('sh-input', className)} {...props} />;
}

function Textarea({ className, ...props }: React.ComponentProps<'textarea'>) {
	return <textarea className={clsx('sh-textarea', className)} {...props} />;
}

function NativeSelect({ className, ...props }: React.ComponentProps<'select'>) {
	return <select className={clsx('sh-select', className)} {...props} />;
}

function Label({ className, ...props }: React.ComponentProps<'label'>) {
	return <label className={clsx('sh-label', className)} {...props} />;
}

function Checkbox({ className, ...props }: React.ComponentProps<'input'>) {
	return <input type="checkbox" className={clsx('sh-checkbox', className)} {...props} />;
}

export { Input, Textarea, NativeSelect, Label, Checkbox };
