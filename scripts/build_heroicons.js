#!/usr/bin/env node
// Heroicons MIT. Regenerate with `npm run build:heroicons`.
// Writes lib/flat_pack/heroicons/paths.json from the heroicons npm package.

"use strict";

const fs = require("fs");
const path = require("path");

const outputFile = path.join(__dirname, "../lib/flat_pack/heroicons/paths.json");

const BUILD_TARGETS = [
  { exportName: "outline", pathParts: ["24", "outline"] },
  { exportName: "solid", pathParts: ["24", "solid"] },
  { exportName: "mini", pathParts: ["20", "solid"] },
  { exportName: "micro", pathParts: ["16", "solid"] },
];

function extractInner(svgContent) {
  const withoutOpen = svgContent.replace(/^<svg[^>]*>\n?/s, "");
  const withoutClose = withoutOpen.replace(/\n?<\/svg>\s*$/s, "");
  return withoutClose.trim();
}

function buildVariant(pathParts) {
  const dir = path.join(__dirname, "../node_modules/heroicons", ...pathParts);
  const files = fs
    .readdirSync(dir)
    .filter((file) => file.endsWith(".svg"))
    .sort();

  const bank = {};
  files.forEach((file) => {
    const name = file.replace(/\.svg$/, "");
    const content = fs.readFileSync(path.join(dir, file), "utf8");
    bank[name] = extractInner(content);
  });
  return bank;
}

const paths = {};
BUILD_TARGETS.forEach(({ exportName, pathParts }) => {
  paths[exportName] = buildVariant(pathParts);
});

const header = "// Heroicons MIT. Regenerate with `npm run build:heroicons`.\n";
fs.mkdirSync(path.dirname(outputFile), { recursive: true });
fs.writeFileSync(outputFile, header + JSON.stringify(paths));
console.log(`Written ${outputFile}`);

const missing = [];
["bug-ant", "chart-bar"].forEach((name) => {
  if (!paths.outline[name]) missing.push(name);
});
if (missing.length > 0) {
  console.error("MISSING icons:", missing.join(", "));
  process.exit(1);
}

console.log("outline bug-ant present, outline chart-bar present");
BUILD_TARGETS.forEach(({ exportName }) => {
  console.log(`Total ${exportName} icons: ${Object.keys(paths[exportName]).length}`);
});
