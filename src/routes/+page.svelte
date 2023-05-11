<script type="ts">
	import dappInfo from '$lib/config/config';
	import { transactionInProgress } from '$stores/FlowStore';
</script>

<section>
	{#if $transactionInProgress}
		<div>aaa</div>
	{/if}
	<div class="container">
		<h1>Welcome to <span>{dappInfo.title}</span></h1>
		<p>{dappInfo.description}</p>
		<p>Crafted by {dappInfo.author}</p>
	</div>
</section>

<style type="scss">
	h1,
	p {
		text-align: center;
	}

	span {
		color: var(--clr-primary-main);
	}
</style>
