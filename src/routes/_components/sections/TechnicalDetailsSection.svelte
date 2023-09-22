<script lang="ts">
	import Orbits from '$lib/components/Orbits.svelte';

	const TECHNICAL_CARDS = [
		{
			title: 'High-traffic performance',
			description:
				'We chose Flow because it can handle high-traffic applications, making it ideal for processing attendance data at large events. Also, it’s focus on mainstream adoption make it ideal for building smooth user experiences.'
		},
		{
			title: 'Truly portable proof of attendance',
			description:
				'By using blockchain, we generate secure NFTs that attendees can keep and transfer.'
		},
		{
			title: 'Powerful Composability',
			description:
				'Because FLOAT is built on the blockchain, our proof of attendance NFTs are truly composable. This means they can be used for much more than just event attendance verification. Communities on Discord can use FLOATs to verify attendance and grant certain roles to members. Smart contracts like Toucans can restrict participation in funding rounds to FLOAT owners. With FLOAT, your NFTs can be used in ways limited only by your imagination!'
		}
	];
</script>

<section>
	<div class="container-small shadow-medium">
		<div class="center column-10" style="z-index: 10">
			<div class="header-wrapper center column-2">
				<h2 class="w-bold">Own your digital stuff</h2>
				<p class="h5">
					We use <strong class="primary">blockchain and NFT</strong> technology to create a
					<strong>secure</strong>
					and
					<strong>transparent</strong> record of event attendance that can't be tampered.
				</p>
			</div>
			<div class="cards-wrapper">
				{#each TECHNICAL_CARDS as card, i}
					<div class="techincal-card" style={`grid-area: card${i + 1}`}>
						<h4 class="h5 w-medium">{card.title}</h4>
						<p class="small">{card.description}</p>
					</div>
				{/each}
			</div>
		</div>
		<div class="orbits-wrapper">
			<Orbits />
		</div>
	</div>
</section>

<style lang="scss">
	.container-small {
		background-color: var(--clr-neutral-50);
		padding: var(--space-10);
		border-radius: var(--radius-9);
		position: relative;
		overflow: hidden;
		display: flex;

		@include mq(small) {
			padding: var(--space-12);
		}

		@include mq(medium) {
			padding: var(--space-16);
		}

		.orbits-wrapper {
			position: absolute;
			left: 100px;
			top: -400px;
		}

		.header-wrapper {
			h2 {
				text-align: center;
				color: var(--clr-heading-inverse);
			}

			p.h5 {
				text-align: center;
				color: var(--clr-text-inverse);

				strong {
					color: var(--clr-heading-inverse);

					&.primary {
						color: var(--clr-primary-600);
					}
				}
			}
		}

		.cards-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-7);

			@include mq('small') {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
				grid-template-rows: repeat(2, auto);
				grid-template-areas:
					'card1 card2'
					'card3 card3';
			}

			.techincal-card {
				background-color: var(--clr-neutral-100);
				border-radius: var(--radius-7);
				padding: var(--space-10);
				border: 1px solid var(--clr-neutral-200);
				transition: 2s;

				&:hover {
					h4 {
						color: var(--clr-primary-800);
					}
				}

				h4 {
					color: var(--clr-heading-inverse);
					margin-bottom: var(--space-3);
					transition: 2s;
				}

				p {
					color: var(--clr-text-inverse);
				}
			}
		}
	}
</style>
