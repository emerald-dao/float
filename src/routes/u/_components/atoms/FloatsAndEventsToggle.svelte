<script lang="ts">
	export let floatsOrEventsView: 'floats' | 'events';

	function handleViewModeChange(buttonType: 'floats' | 'events') {
		floatsOrEventsView = buttonType;
	}
</script>

<button on:click={() => handleViewModeChange('floats')}>
	<h4 class="h5" class:selected={floatsOrEventsView === 'floats'}>FLOATs</h4>
</button>
<h4 class="h5">|</h4>
<button on:click={() => handleViewModeChange('events')}>
	<h4 class="h5" class:selected={floatsOrEventsView === 'events'}>Events</h4>
</button>

<style lang="scss">
	button {
		background: none;
		border: none;
	}
	h4 {
		color: var(--clr-neutral-600);
		cursor: pointer;
	}
	h4.selected {
		color: var(--clr-heading-main);
	}
</style>
