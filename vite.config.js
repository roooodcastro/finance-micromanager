import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import VuePlugin from '@vitejs/plugin-vue';

export default defineConfig({
  build: {
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
  },
  plugins: [
    RubyPlugin(),
    VuePlugin(),
  ],
});
