# How to use the Flow Client Library (FCL) with SvelteKit

Everything you need to build a SvelteKit project with the Flow Client Library (FCL).

For a NextJS example, see my other repo: https://github.com/muttoni/fcl-nextjs-quickstart

## [Live demo](https://fcl-sveltekit.vercel.app/)

[![image](https://user-images.githubusercontent.com/27052451/146340356-e34f3c47-43bc-4c11-926b-b82b99d561c6.png)](https://fcl-sveltekit.vercel.app/)


## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

Before creating a production version of your app, install an [adapter](https://kit.svelte.dev/docs#adapters) for your target environment. Then:

```bash
npm run build
```

> You can preview the built app with `npm run preview`, regardless of whether you installed an adapter. This should _not_ be used to serve your app in production.
