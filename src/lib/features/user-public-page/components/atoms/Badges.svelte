<script type="ts">
	import Icon from '@iconify/svelte';

	export let badges: Badges[];

	interface Badges {
		icon: string;
		name: string;
	}
</script>

<div class="badges-wrapper">
	{#each badges as badge}
		<div class="main-wrapper">
			<div class="background">
				<Icon icon={badge.icon} color="var(--clr-tertiary-main)" />
			</div>
			<p class="small">{badge.name}</p>
		</div>
	{/each}
</div>

<style type="scss">
	.badges-wrapper {
		display: grid;
		grid-template-columns: repeat(3, 1fr);

		.main-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			margin-bottom: var(--space-8);

			.background {
				display: flex;
				flex-direction: column;
				justify-content: center;
				align-items: center;
				background-color: rgba(255, 102, 196, 0.1);
				width: 40px;
				height: 40px;
				border-radius: 50%;
				margin-bottom: var(--space-3);
			}
		}
	}
</style>
