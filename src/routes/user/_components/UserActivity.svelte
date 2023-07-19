<script lang="ts">
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

<style lang="scss">
	section {
		padding-block: 0;

		@include mq(small) {
			padding-block: 4rem;
		}

		.header-wrapper {
			display: none;
			border-bottom: 1px dashed var(--clr-border-primary);

			@include mq(small) {
				display: grid;
				grid-template-columns: repeat(3, 1fr);
				justify-content: center;
				align-items: center;
				text-align: center;
				position: sticky;
				top: 0;
				z-index: 1000;
				background-color: var(--clr-background-primary);
				padding: var(--space-2) 0;
			}

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
	}
</style>
