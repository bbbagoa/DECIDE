import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { fileURLToPath } from "node:url";

const src = (p: string) => fileURLToPath(new URL(`./src/${p}`, import.meta.url));

// The client is built into the R package (inst/app/react/ui.js + ui.css) so
// installing TargetWise never needs Node.
//
// ONE React: "react" and "react-dom/client" resolve to modules that re-export
// window.shinyreact's (src/shims/), so every package, ESM or CommonJS, shares
// the React that owns the shinyreact hooks (a second React makes every hook
// silently return nothing). Marking them external is not enough: CommonJS
// packages (use-sync-external-store, used by recharts and react-select) kept a
// require("react") the browser cannot run. The small main "react-dom"
// (createPortal) is bundled; it takes its React from the same shim.
// `vite build --mode gallery` builds the toolkit gallery instead (dev/gallery:
// a test app for src/lib, run by dev/gallery/test.R).
export default defineConfig(({ mode }) => { const gallery = mode === "gallery"; return {
  define: { "process.env.NODE_ENV": JSON.stringify("production") },
  plugins: [react()],
  resolve: {
    alias: [
      { find: /^react$/, replacement: src("shims/react.ts") },
      { find: /^react-dom\/client$/, replacement: src("shims/react-dom-client.ts") },
      { find: /^@\//, replacement: src("") },
    ],
  },
  build: {
    outDir: gallery ? "dev/gallery/www" : "../inst/app/react",
    // the folder holds only this build: old chunks go
    emptyOutDir: true,
    cssCodeSplit: false,
    sourcemap: false,
    lib: { entry: gallery ? "dev/gallery/gallery.tsx" : "src/ui.tsx", formats: ["es"], fileName: () => "ui.js" },
    // an ES module (shinyreact loads ui.js as type="module"), so heavy
    // libraries (ECharts, the map) are chunks loaded when first needed
    rollupOptions: { output: { assetFileNames: "ui.[ext]", chunkFileNames: "chunks/[name]-[hash].js" } },
  },
};});
