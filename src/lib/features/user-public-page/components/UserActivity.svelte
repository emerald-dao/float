<script type="ts">
	import { Tab, TabList, TabPanel, Tabs } from '@emerald-dao/component-library';
	import type { Event } from '$lib/types/event/event.interface';
	import UserCollection from './sections/UserCollection.svelte';
	import UserChallenges from './sections/UserChallenges.svelte';

	export let contentList: Event[];
</script>

<Tabs>
	<section class="container">
		<div class="header-wrapper">
			<div class="row">
				<img src="/test-toucan.png" alt="float" />
				<p>mateor.find</p>
			</div>
			<div class="tabs-wrapper">
				<TabList>
					<Tab><span class="xsmall">Main Funders</span></Tab>
					<Tab><span class="xsmall">Main Holders</span></Tab>
				</TabList>
			</div>
			<div>
				<p>26 FLOATs</p>
			</div>
		</div>
		<div>
			<TabPanel>
				<UserCollection {contentList} />
			</TabPanel>
			<TabPanel>
				<UserChallenges {contentList} />
			</TabPanel>
		</div>
	</section>
</Tabs>

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

		.tabs-wrapper {
			align-content: center;
			width: fit-content;
		}
	}
</style>
