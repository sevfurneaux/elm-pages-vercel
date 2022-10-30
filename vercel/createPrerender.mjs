import fs from "fs-extra";
import { createServerlessFunction } from "./createServerlessFunction.mjs";

export async function createPrerender(
  pageName,
  renderFunctionFilePath,
  portsFilePath,
  htmlTemplate,
  prerenderConfig
) {
  const funcFolder = `.vercel/output/functions/${pageName}.func`;
  await fs.ensureDir(funcFolder);

  try {
    await createServerlessFunction(
      pageName,
      renderFunctionFilePath,
      portsFilePath,
      htmlTemplate,
      true
    );

    return fs.writeJson(
      `.vercel/output/functions/${pageName}.prerender-config.json`,
      prerenderConfig
    );
  } catch (e) {
    console.log(e);
  }
}
