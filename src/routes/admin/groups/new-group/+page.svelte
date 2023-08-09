<script>
	import { user } from '$stores/flow/FlowStore';
	import { Button } from '@emerald-dao/component-library';
</script>

<form method="POST">
	<label>
		Group name
		<input name="name" type="text" />
	</label>
	<label>
		Description
		<input name="description" type="text" />
	</label>
	<input name="user_address" type="hidden" value={$user.addr} />
	<Button>Create group</Button>
</form>
