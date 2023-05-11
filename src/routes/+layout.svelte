<script type="ts">
	import '../app.postcss';
	import '@emerald-dao/design-system/build/variables-dark.css';
	import '@emerald-dao/design-system/build/variables-light.css';
	import '@emerald-dao/design-system/build/variables.css';
	import '@emerald-dao/component-library/styles/app.scss';
	import { Header, Footer } from '@emerald-dao/component-library';
	import { navElements, emeraldTools, socialMedia } from '$lib/config/navigation';
	import { theme } from '$stores/ThemeStore';
	import { logIn, unauthenticate } from '$flow/actions';
	import { user } from '$stores/FlowStore';
	import { browser } from '$app/environment';
</script>

<Header themeStore={theme} user={$user} />
<main>
	<slot />
</main>
<Footer {navElements} {emeraldTools} socials={socialMedia} />
