import { join } from "path";
import fs from "fs-extra";
import { createPrerender } from "./vercel/createPrerender.mjs";
import { createServerlessFunction } from "./vercel/createServerlessFunction.mjs";
import elmPagesConfig from "./elm-pages.config.mjs";

const VERCEL_OUTPUT_DIR = join(".vercel", "output");
const VERCEL_STATIC_DIR = join(VERCEL_OUTPUT_DIR, "static");
const ELM_PAGES_DIST_DIR = "dist";

export default async function run({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
  portsFilePath,
  htmlTemplate,
}) {
  console.log("Running adapter script");

  try {
    await prepareFileSystem();

    if (fs.existsSync(ELM_PAGES_DIST_DIR)) {
      await fs.copy(ELM_PAGES_DIST_DIR, VERCEL_STATIC_DIR);
    }

    const prerenderConfig = {
      expiration:
        elmPagesConfig?.vercel?.preRenderWithFallback?.expiration ?? 60,
      allowQuery: ["slug"],
    };

    await Promise.allSettled([
      createPrerender(
        "isr",
        renderFunctionFilePath,
        portsFilePath,
        htmlTemplate,
        prerenderConfig
      ),
      createServerlessFunction(
        "serverless",
        renderFunctionFilePath,
        portsFilePath,
        htmlTemplate
      ),
    ]);

    const serverlessRoutes = routePatterns
      .filter(
        (route) =>
          route.kind === "prerender-with-fallback" ||
          route.kind === "serverless"
      )
      .map((route) => {
        const dest =
          route.kind === "prerender-with-fallback" ? "/isr" : "/serverless";

        if (route.kind === "prerender-with-fallback") {
          const source = `/${route.pathPattern
            .substring(1)
            .split("/")
            .map((path) => {
              if (path.includes(":")) {
                return `(?<${path.replace(":", "")}>[^/]*)`;
              } else {
                return `(?<${path}>${path})`;
              }
            })
            .join("/")}`;
          return [
            { src: source, dest, check: true },
            {
              src: `${source}/(?<content>content.dat)`,
              dest: dest,
              check: true,
            },
          ];
        } else {
          const source = `/${route.pathPattern
            .substring(1)
            .split("/")
            .map((path) => {
              if (path.includes(":")) {
                return `([^/]*)`;
              } else {
                return path;
              }
            })
            .join("/")}`;
          return [
            { src: source, dest, check: true },
            {
              src: `${source}/content.dat`,
              dest,
              check: true,
            },
          ];
        }
      })
      .flat();

    fs.writeJSON(join(VERCEL_OUTPUT_DIR, "config.json"), {
      images: elmPagesConfig?.vercel?.images ?? null,
      version: 3,
      routes: [
        {
          src: "^/(?:(.+)/)?index(?:\\.html)?/?$",
          headers: { Location: "/$1" },
          status: 308,
        },
        {
          src: "^/(.*)\\.html/?$",
          headers: { Location: "/$1" },
          status: 308,
        },
        { handle: "filesystem" },
        ...serverlessRoutes,
      ],
    });
  } catch (error) {
    console.log(error);
  }
}

async function prepareFileSystem() {
  await fs.emptyDir(VERCEL_OUTPUT_DIR);
  return Promise.allSettled([fs.ensureDir(VERCEL_STATIC_DIR)]);
}
