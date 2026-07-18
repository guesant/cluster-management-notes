import * as React from 'react';
import { clsx } from 'clsx';

type ButtonVariant = 'default' | 'outline' | 'ghost';
type ButtonSize = 'default' | 'sm' | 'icon';

const variantClasses: Record<ButtonVariant, string | null> = {
	default: null,
	outline: 'sh-btn--outline',
	ghost: 'sh-btn--ghost',
};

const sizeClasses: Record<ButtonSize, string | null> = {
	default: null,
	sm: 'sh-btn--sm',
	icon: 'sh-btn--icon',
};

function Button({
	className,
	variant = 'default',
	size = 'default',
	...props
}: React.ComponentProps<'button'> & { variant?: ButtonVariant; size?: ButtonSize }) {
	return (
		<button
			type="button"
			className={clsx('sh-btn', variantClasses[variant], sizeClasses[size], className)}
			{...props}
		/>
	);
}

export { Button };
