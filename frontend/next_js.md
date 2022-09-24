# Next.js Guide

# Getting Started
#### [Creating new app](#creating-new-app)
#### [Manual Setup](#manual-setup)
#### [Deployment](#deployment)

## Creating new app
Use `--typescript` flag if desired
```
npx create-next-app@latest
# or
yarn create next-app
# or
pnpm create next-app
```
After the installation is complete:
* Run `npm run dev` or `yarn dev` or `pnpm dev` to start the development server on http://localhost:3000
* Visit http://localhost:3000 to view your application
* Edit pages/index.js and see the updated result in your browser
For more information on how to use `create-next-app`, you can review the
[create-next-app documentation](https://nextjs.org/docs/api-reference/create-next-app).

### Manual Setup
```
npm install next react react-dom
# or
yarn add next react react-dom
# or
pnpm add next react react-dom
```
Edit `package.json`:
```
"scripts": {
  "dev": "next dev",
  "build": "next build",
  "start": "next start",
  "lint": "next lint"
}
```
Create two directories pages and public at the root of your application:
* `pages` - Associated with a route based on their file name. For example `pages/about.js` is
mapped to `/about`
* `public` - Stores static assets such as images, fonts, etc. Files inside `public` directory
can then be referenced by your code starting from the base URL (/).

Next.js is built around the concept of pages. A page is a React Component exported from
a `.js`, `.jsx`, `.ts`, or `.tsx` file in the `pages` directory. You can even add dynamic
route parameters with the filename.

Inside the pages directory add the index.js file to get started. This is the page that is
rendered when the user visits the root of your application.

Populate `pages/index.js` with the following contents:
```
function HomePage() {
  return <div>Welcome to Next.js!</div>
}

export default HomePage
```
So far, we get:
* Automatic compilation and bundling
* React Fast Refresh
* Static generation and server-side rendering of `pages/`
* Static file serving through `public/` which is mapped to the base URL (`/`)
In addition, any Next.js application is ready for production from the start. Read
more in our [Deployment documentation](https://nextjs.org/docs/deployment).

## Incremental Static Regeneration
Next.js allows you to create or update static pages after you’ve built your site. Incremental Static 
Regeneration (ISR) enables you to use static-generation on a per-page basis, without needing to rebuild
the entire site. With ISR, you can retain the benefits of static while scaling to millions of pages.

To use ISR, add the `revalidate` prop to `getStaticProps`:
```javascript
function Blog({ posts }) {
  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}

// This function gets called at build time on server-side.
// It may be called again, on a serverless function, if
// revalidation is enabled and a new request comes in
export async function getStaticProps() {
  const res = await fetch('https://.../posts')
  const posts = await res.json()

  return {
    props: {
      posts,
    },
    // Next.js will attempt to re-generate the page:
    // - When a request comes in
    // - At most once every 10 seconds
    revalidate: 10, // In seconds
  }
}

// This function gets called at build time on server-side.
// It may be called again, on a serverless function, if
// the path has not been generated.
export async function getStaticPaths() {
  const res = await fetch('https://.../posts')
  const posts = await res.json()

  // Get the paths we want to pre-render based on posts
  const paths = posts.map((post) => ({
    params: { id: post.id },
  }))

  // We'll pre-render only these paths at build time.
  // { fallback: blocking } will server-render pages
  // on-demand if the path doesn't exist.
  return { paths, fallback: 'blocking' }
}

export default Blog
```
When a request is made to a page that was pre-rendered at build time, it will initially show the cached page.
* Any requests to the page after the initial request and before 10 seconds are also cached and instantaneous.
* After the 10-second window, the next request will still show the cached (stale) page
* Next.js triggers a regeneration of the page in the background.
* Once the page generates successfully, Next.js will invalidate the cache and show the updated page. If the background 
regeneration fails, the old page would still be unaltered.
> Note: Check if your upstream data provider has caching enabled by default. You might need to 
> disable (e.g. useCdn: false), otherwise a revalidation won't be able to pull fresh data to update
> the ISR cache. Caching can occur at a CDN (for an endpoint being requested) when it
> returns the Cache-Control header.
## Deployment
`next build` generates an optimized version of your application for production. This standard output includes:
* HTML files for pages using getStaticProps or Automatic Static Optimization
* CSS files for global styles or for individually scoped styles
* JavaScript for pre-rendering dynamic content from the Next.js server
* JavaScript for interactivity on the client-side through React
* This output is generated inside the .next folder:

    * `.next/static/chunks/pages` – Each JavaScript file inside this folder relates to the route with the same name. For example, .next/static/chunks/pages/about.js would be the JavaScript file loaded when viewing the /about route in your application
    * `.next/static/media` – Statically imported images from next/image are hashed and copied here
    * `.next/static/css` – Global CSS files for all pages in your application
    * `.next/server/pages`– The HTML and JavaScript entry points prerendered from the server. The .nft.json files are created when Output File Tracing is enabled and contain all the file paths that depend on a given page.
    * `.next/server/chunks` – Shared JavaScript chunks used in multiple places throughout your application
    * `.next/cache` – Output for the build cache and cached images, responses, and pages from the Next.js server. Using a cache helps decrease build times and improve performance of loading images
All JavaScript code inside `.next` has been compiled and browser bundles have been minified to help 
achieve the best performance and support all modern browsers.
### Docker
https://github.com/vercel/next.js/tree/canary/examples/with-docker

To add support for Docker to an existing project, just copy the `Dockerfile` into the root of the 
project and add the following to the `next.config.js` file:
```
// next.config.js
module.exports = {
  // ... rest of the configuration.
  output: 'standalone',
}
```
This will build the project as a standalone app inside the Docker image.

### Kubernetes
Incremental Static Regeneration (ISR) works on self-hosted Next.js sites out of the box 
when you use next start. You can use this approach when deploying to container orchestrators
such as Kubernetes or HashiCorp Nomad. By default, generated assets will be stored in-memory
on each pod. This means that each pod will have its own copy of the static files. Stale data may 
be shown until that specific pod is hit by a request.

To ensure consistency across all pods, you can disable in-memory caching. This will inform the
Next.js server to only leverage assets generated by ISR in the file system.

You can use a shared network mount in your Kubernetes pods (or similar setup) to reuse the same file-system
cache between different containers. By sharing the same mount, the .next folder which contains the next/image 
cache will also be shared and re-used.

To disable in-memory caching, set isrMemoryCacheSize to 0 in your next.config.js file:
```
module.exports = {
  experimental: {
    // Defaults to 50MB
    isrMemoryCacheSize: 0,
  },
}
```
> Note: You might need to consider a race condition between multiple pods trying to update the 
> cache at the same time, depending on how your shared mount is configured.

