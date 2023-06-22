<script type="ts">
	import type { Event } from '$lib/types/event/event.interface';
	import UserCollection from './sections/UserCollection.svelte';

	export let contentList: Event[];
</script>

<section class="container">
	<div class="header-wrapper">
		<div class="row">
			<img src="/test-toucan.png" alt="float" />
			<p>mateor.find</p>
		</div>
		<div class="title-wrapper">
			<h4 class="xsmall">Collection</h4>
		</div>
		<div class="right-wrapper">
			<p>26 FLOATs</p>
		</div>
	</div>
	<div>
		<UserCollection {contentList} />
	</div>
</section>

<style type="scss">
	section {
		padding-block: 0;

		@include mq(small) {
			padding-block: 4rem;
		}
		.header-wrapper {
			display: none;

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
