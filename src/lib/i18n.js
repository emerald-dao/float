import { register, init, getLocaleFromNavigator } from 'svelte-i18n'

register('en', () => import('../locales/en.json'));
// not available yet

init({
  fallbackLocale: 'en',
  initialLocale: getLocaleFromNavigator(),
});
// starts loading 'en'
