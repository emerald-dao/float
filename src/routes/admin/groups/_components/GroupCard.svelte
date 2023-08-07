<script lang="ts">
	import type { Group } from '../_types/group.interface';

	export let group: Group;
</script>

<a class="card" href={`/admin/groups/${group.id}`}>
	<h5 class="card-title">{group.name}</h5>
	<p class="card-text">{group.description}</p>
	<a href="/admin/groups/{group.id}" class="btn btn-primary">View</a>
</a>
