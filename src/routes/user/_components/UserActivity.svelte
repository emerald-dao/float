<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { User } from '$lib/types/user/user.interface';
	import UserCollection from './sections/UserCollection.svelte';

	export let floats: FLOAT[];
	export let userData: User;
</script>

<div class="header-wrapper">
	<div class="container-medium">
		<div class="row">
			<img src={userData.image} alt="user avatar" />
			<p class="large">{userData.name}</p>
		</div>
		<div class="title-wrapper">
			<h4 class="h5">User collection</h4>
		</div>
		<div class="right-wrapper">
			<p class="small">{`${floats.length} FLOATs`}</p>
		</div>
	</div>
</div>
<section class="container">
	<div>
		<UserCollection {floats} />
	</div>
</section>

<style lang="scss">
	section {
		padding-block: 0;

		@include mq(small) {
			padding-block: 4rem;
		}
	}

	.header-wrapper {
		display: none;

		@include mq(small) {
			display: flex;
			position: sticky;
			top: 0;
			z-index: 1000;
			margin-top: var(--space-6);
			background-color: var(--clr-background-primary);
		}

		.container-medium {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			justify-content: center;
			align-items: center;
			text-align: center;
			padding: var(--space-3) 0;
		}

		.row {
			align-items: center;
			gap: var(--space-4);

			img {
				width: 47px;
				height: 47px;
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
