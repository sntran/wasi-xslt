import Context from "https://deno.land/std@0.206.0/wasi/snapshot_preview1.ts";
import { parseArgs } from "https://deno.land/std@0.210.0/cli/parse_args.ts";
import { resolve } from "https://deno.land/std@0.210.0/path/mod.ts";

const binary = await fetch(new URL("./xsltproc.wasm", import.meta.url)).then((
  res,
) => res.arrayBuffer());
const module = await WebAssembly.compile(binary);

const cwd = Deno.cwd();

/**
 * Applies XSLT stylesheets to XML documents.
 * @param {Object} options
 * @param {string} stylesheet
 * @param  {string[]} documents
 */
function xsltproc(
  options: Record<string, unknown>,
  stylesheet: string,
  ...documents: string[]
) {
  const args = ["xsltproc"];

  Object.entries(options).forEach(([key, value]) => {
    args.push(`--${key}`);
    if (value && value !== true) {
      args.push(value.toString());
    }
  });

  const params = [stylesheet, ...documents].filter(Boolean).map((file) =>
    resolve(cwd, file)
  );
  args.push(...params);

  const preopens = params.reduce((acc, file) => {
    const folder = file.split("/").slice(0, -1).join("/");
    acc[folder] = folder;
    return acc;
  }, {} as Record<string, string>);

  const context = new Context({
    env: Deno.env.toObject(),
    args,
    preopens,
  });

  const instance = new WebAssembly.Instance(module, {
    "wasi_snapshot_preview1": context.exports,
  });

  context.start(instance);
}

if (import.meta.main) {
  const {
    _: [stylesheet, ...documents],
    ...flags
  } = parseArgs(Deno.args);

  xsltproc(flags, stylesheet as string, ...documents as string[]);
}
