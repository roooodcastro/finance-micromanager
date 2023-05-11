import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import VuePlugin from '@vitejs/plugin-vue';
import { resolve } from 'path';
import { fileURLToPath, URL } from "url";

export default defineConfig({
  root: resolve(__dirname, 'app/javascript'),
  build: {
    resolve: {
      alias: [
        { find: '~bootstrap', replacement: fileURLToPath(new URL('./node_modules/bootstrap', import.meta.url)) },
        { find: '@', replacement: fileURLToPath(new URL('./app/javascript', import.meta.url)) },
      ]
    },
    rollupOptions: {
      // make sure to externalize deps that shouldn't be bundled
      // into your library
      external: ['vue'],
      output: {
        // Provide global variables to use in the UMD build
        // for externalized deps
        globals: {
          vue: 'Vue'
        },
      },
    },
    sourcemap: true,
  },
  plugins: [
    RubyPlugin(),
    VuePlugin(),
  ],
});
