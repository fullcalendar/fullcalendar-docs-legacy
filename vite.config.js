import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'

const projectRoot = path.dirname(fileURLToPath(import.meta.url))

export default defineConfig(({ mode }) => ({
  css: {
    preprocessorOptions: {
      scss: {
        silenceDeprecations: ['import'],
      },
    },
  },
  build: {
    assetsDir: '',
    cssCodeSplit: true,
    emptyOutDir: false,
    minify: mode === 'production',
    modulePreload: {
      polyfill: false,
    },
    outDir: '_site/dist',
    rolldownOptions: {
      input: {
        base: path.resolve(projectRoot, 'src/styles/base.scss'),
        docs: path.resolve(projectRoot, 'src/docs.js'),
        demos: path.resolve(projectRoot, 'src/demos.js'),
        'demo-to-codepen': path.resolve(projectRoot, 'src/demo-to-codepen.js'),
        'theme-chooser': path.resolve(projectRoot, 'src/theme-chooser.js'),
      },
      output: {
        assetFileNames: (assetInfo) => {
          const name = assetInfo.names[0] || 'asset'

          return name.endsWith('.css')
            ? '[name][extname]'
            : 'assets/[name]-[hash][extname]'
        },
        chunkFileNames: 'chunks/[name]-[hash].js',
        entryFileNames: '[name].js',
      },
    },
    sourcemap: mode === 'development' ? 'inline' : false,
  },
}))
