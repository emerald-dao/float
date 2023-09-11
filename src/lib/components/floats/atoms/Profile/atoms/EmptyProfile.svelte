<script lang="ts">
	export let inverse = false;
</script>

<div class="main-wrapper row align-center" class:inverse>
	<div class="creator-avatar" />
	<div class="profile-wrapper">
		<div class="line" />
		<div class="line" />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		width: 100%;
		gap: 0.4em;

		div.creator-avatar {
			background: var(--clr-background-secondary);
			width: 2em;
			height: 2em;
			border-radius: 50%;
		}

		.profile-wrapper {
			display: flex;
			flex-direction: column;
			gap: 0.1em;
			flex: 1;

			.line {
				width: 100%;
				height: 0.3em;
				margin-block: 0.2em;
				background: var(--clr-background-secondary);
				border-radius: 0.2em;
			}
		}
	}
</style>
