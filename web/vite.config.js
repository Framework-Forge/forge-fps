import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
export default defineConfig({base:'./',plugins:[svelte()],build:{target:'chrome103',emptyOutDir:true}});
