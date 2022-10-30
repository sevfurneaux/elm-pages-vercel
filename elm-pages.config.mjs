import { defineConfig } from "vite";

import adapter from "./adapter.mjs";

export default {
  vite: defineConfig({}),
  adapter,
  vercel: {
    images: {
      sizes: [450, 1125],
      domains: ["cdn.shopify.com"],
      formats: ["image/webp", "image/avif"],
    },
    preRenderWithFallback: {
      expiration: 60,
    },
  },
};
