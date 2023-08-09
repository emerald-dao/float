<script>
	import { user } from '$stores/flow/FlowStore';
	import { Button } from '@emerald-dao/component-library';
</script>

<form method="POST" class="column-6">
	<div class="column-4">
		<label>
			Group name
			<input name="name" type="text" />
		</label>
		<label>
			Description
			<input name="description" type="text" />
		</label>
		<input name="user_address" type="hidden" value={$user.addr} />
	</div>
	<Button>Create group</Button>
</form>

<style lang="scss">
	form {
		padding: var(--space-12) var(--space-18);
	}
</style>
