import { svelte } from '@sveltejs/vite-plugin-svelte'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import path from 'path'

export default defineConfig({
  plugins: [
    svelte(),
    tailwindcss(),
    RubyPlugin(),
  ],
  server: {
    host: 'localhost',
    strictPort: true,
    hmr: {
      host: 'localhost'
    },
  },
  resolve: {
    alias: {
      '@components': path.resolve(__dirname, 'app/frontend/components')
    }
  }
})
