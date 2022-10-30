> **Warning**
> This elm-pages 3.0 alpha Vercel adapter is very much a work in progress, so can also be considered alpha.

# elm-pages 3.0 alpha Vercel adapter

This is a work in progress of deploying elm-pages 3.0 alpha on [Vercel](https://vercel.com).

## Status

- [x] `RouteBuilder.preRender` ([Static Files](https://vercel.com/docs/build-output-api/v3#vercel-primitives/static-files))
- [x] `RouteBuilder.preRenderWithFallback` ([Prerender Functions](https://vercel.com/docs/build-output-api/v3#vercel-primitives/prerender-functions))
- [x] `RouteBuilder.serverRender` ([Serverless Functions](https://vercel.com/docs/build-output-api/v3#vercel-primitives/serverless-functions))
- [ ] `ApiRoute.preRender`
- [ ] `ApiRoute.preRenderWithFallback`
- [ ] `ApiRoute.preRenderWithFallback`
- [ ] `ApiRoute.serverRender`

## Deployment

The current implementation uses [Vercel's Build Output API (v3)](https://vercel.com/docs/build-output-api/v3#) for deployment. This means the project is built locally (`yarn build`) and then deployed using `yarn deploy` (`vercel deploy --prebuilt --prod`).

In the future, it'll hopefully be possible to deploy through Vercel's normal build pipeline 🤞.

## `RouteBuilder.preRenderWithFallback`

`RouteBuilder.preRenderWithFallback` uses Vercel's [Prerender Functions](https://vercel.com/docs/build-output-api/v3#vercel-primitives/prerender-functions) to cache the output on Vercel's Edge Network.

An `expiration` property can be set in [elm-pages.config.mjs](elm-pages.config.mjs) which sets the expiration time before the cached asset will be re-generated by invoking the Serverless Function:

```
export default {
  vite: defineConfig({}),
  adapter,
  vercel: {
    preRenderWithFallback: {
      expiration: 60,
    },
  },
};
```
