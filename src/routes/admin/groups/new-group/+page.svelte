<script>
	import { user } from '$stores/flow/FlowStore';
	import { Button } from '@emerald-dao/component-library';
	import { enhance } from '$app/forms';
	import { getContext } from 'svelte';

	const groups = getContext('groups');

	let name = '';
</script>

<form
	method="POST"
	class="column-6"
	use:enhance={() => {
		return async ({ update }) => {
			groups.invalidate();
			update();
		};
	}}
>
	<h4>Create new group</h4>
	<div class="column-4">
		<label>
			Group name
			<input name="name" type="text" maxlength="40" bind:value={name} />
		</label>
		<label>
			Description
			<textarea name="description" maxlength="100" />
		</label>
		<input name="user_address" type="hidden" value={$user.addr} />
	</div>
	<Button state={name.length > 0 ? 'active' : 'disabled'}>Create group</Button>
</form>

<style lang="scss">
	h4 {
		font-size: var(--font-size-4);
	}

	form {
		padding: var(--space-10) var(--space-12);
	}
</style>
