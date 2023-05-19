<script type="ts">
	import '../app.postcss';
	import '@emerald-dao/design-system/build/variables-dark.css';
	import '@emerald-dao/design-system/build/variables-light.css';
	import '@emerald-dao/design-system/build/variables.css';
	import '@emerald-dao/component-library/styles/app.scss';
	import { Header, Footer } from '@emerald-dao/component-library';
	import { navElements, emeraldTools, socialMedia } from '$lib/config/navigation';
	import { theme } from '$stores/ThemeStore';
	import { user } from '$stores/FlowStore';
</script>

<Header themeStore={theme} user={$user} {navElements} />
<main>
	<slot />
</main>
<Footer {navElements} {emeraldTools} socials={socialMedia} />

<style type="scss">
	main {
		display: flex;
		flex-direction: column;
		min-width: 0;
	}
</style>
