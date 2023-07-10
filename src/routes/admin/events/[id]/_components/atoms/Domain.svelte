<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';
	import Link from './Link.svelte';

	export let event: Event;
	export let user: {};
</script>

<div class="domains-wrapper">
	<div class="row-1">
		<Icon icon="ph:link" color="var(--clr-neutral-600)" />
		<p>DOMAINS</p>
	</div>
	<Link id={event.eventId} page={true} {user} />
	<Link id={event.eventId} qr={true} {user} />
</div>

<style lang="scss">
	.domains-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);

		.row-1 {
			align-items: center;
			p {
				color: var(--clr-text-off);
			}
		}
	}
</style>
