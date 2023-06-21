<script type="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { User } from '$lib/types/user/user.interface';
	import UserCollection from './sections/UserCollection.svelte';

	export let floats: FLOAT[];
	export let userData: User;
</script>

<section class="container">
	<div class="header-wrapper">
		<div class="row">
			<img src={userData.image} alt="float" />
			<p>{userData.name}</p>
		</div>
		<div class="title-wrapper">
			<h4 class="xsmall">Collection</h4>
		</div>
		<div class="right-wrapper">
			<p>{`${floats.length} FLOATs`}</p>
		</div>
	</div>
	<div>
		<UserCollection {floats} />
	</div>
</section>

<style type="scss">
	.header-wrapper {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		justify-content: center;
		align-items: center;
		text-align: center;
		position: sticky;
		top: 10px;
		z-index: 1000;
		background-color: var(--clr-background-primary);

		.row {
			align-items: center;
			gap: var(--space-4);

			img {
				width: 56px;
				height: 56px;
				border-radius: 50%;
			}

			p {
				color: var(--clr-heading-main);
			}
		}

		.title-wrapper {
			text-align: center;
		}

		.right-wrapper {
			text-align: right;
		}
	}
</style>
