// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-05-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/supabase'],

  // supabase: {
  //   redirectOptions: {
  //     login: '/login',
  //     callback: '/confirm',
  //     exclude: ['/', '/register'],
  //   }
  // },
  supabase: {
    redirect: false,
  },

  app: {
    head: {
      script: [
        {
          src: "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"
        }
      ]
    }
  }
})