import fs from "fs-extra";
import path from "path";
import { build, transform } from "esbuild";

export async function createServerlessFunction(
  pageName,
  renderFunctionFilePath,
  portsFilePath,
  htmlTemplate,
  isPrerender = false
) {
  const funcFolder = `.vercel/output/functions/${pageName}.func`;
  await fs.ensureDir(funcFolder);

  try {
    await generateLambdaBundle({
      funcFolder,
      renderFunctionFilePath,
      portsFilePath,
      htmlTemplate,
      isPrerender,
    });

    return fs.writeJson(`${funcFolder}/.vc-config.json`, {
      runtime: "nodejs16.x",
      handler: "index.js",
      launcherType: "Nodejs",
      shouldAddHelpers: true,
    });
  } catch (e) {
    console.error(e);
  }
}

export async function generateLambdaBundle({
  funcFolder,
  renderFunctionFilePath,
  portsFilePath,
  htmlTemplate,
  isPrerender,
}) {
  const { code: contents } = await transform(
    `
        const requestTime = new Date();
        global.staticHttpCache = {};

        const { parse } = require('querystring');

        const htmlTemplate = ${JSON.stringify(htmlTemplate)};
        const compiledElmPath = require("${renderFunctionFilePath}");
        const compiledPortsFile = "${portsFilePath}";
        const renderer = require("elm-pages/generator/src/render");
        const preRenderHtml = require("elm-pages/generator/src/pre-render-html");
  
        export default (req, res) => {
          const basePath = "/";
          const mode = "build";
          const addWatcher = () => {};

          const matches = parse(req.headers['x-now-route-matches']);
          

          let body = null;

          req.on("data", function (data) {
            if (!body) {
              body = "";
            }
            body += data;
          });

          ${
            isPrerender
              ? `const url = new URL(Object.keys(matches).sort().filter((item) => parseInt(item)).map((item) => matches[item]).join("/"), \`http://\${req.headers.host}\`);`
              : `const url = new URL(req.url, \`http://\${req.headers.host}\`);`
          }
    
          renderer(
            compiledPortsFile,
            basePath,
            compiledElmPath,
            mode,
            url.pathname,
            toJsonHelper(req, url, body, requestTime),
            addWatcher,
            false
          ).then((renderResult) => {
            const statusCode = renderResult.is404 ? 404 : renderResult.statusCode;

            if (renderResult.kind === "bytes") {
              res.writeHead(statusCode, {
                "Content-Type": "application/octet-stream",
                ...renderResult.headers,
              });
              res.end(Buffer.from(renderResult.contentDatPayload.buffer));
            } else {
              res.writeHead(statusCode, {
                "Content-Type": "text/html",
                "x-powered-by": "elm-pages",
                ...renderResult.headers,
              });
              res.end(preRenderHtml.replaceTemplate(htmlTemplate, renderResult.htmlString));
            }
          });
        }

        function toJsonHelper(req, url, body, requestTime) {
          return {
            method: req.method,
            headers: req.headers || {},
            rawUrl: url.toString(),
            body: body,
            requestTime: Math.round(requestTime.getTime()),
            multiPartFormData: null,
          };
        }
      `,
    {
      target: "node16",
      format: "cjs",
    }
  );

  try {
    return await build({
      platform: "node",
      target: "node16",
      format: "cjs",
      bundle: true,
      allowOverwrite: true,
      treeShaking: true,
      minify: true,
      loader: { ".ts": "ts", ".tsx": "tsx" },
      legalComments: "none",
      stdin: { contents, resolveDir: path.join(".") },
      outfile: `${funcFolder}/index.js`,
      logLevel: "error",
    });
  } catch (e) {
    console.error(e);
  }
}
