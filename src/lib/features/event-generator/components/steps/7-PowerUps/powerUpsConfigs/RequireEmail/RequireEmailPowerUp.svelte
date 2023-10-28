<script lang="ts">
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { POWER_UPS, powerUpsValidations } from '../../powerUps';

	const powerUpData = POWER_UPS['requireEmail'];
	$powerUpsValidations.requireEmail = true;
</script>

<PowerUpConfigWrapper {powerUpData} powerUpType="requireEmail" />
