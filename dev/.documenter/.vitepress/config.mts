import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

function getBaseRepository(base: string): string {
  if (!base || base === '/') return '/';
  const parts = base.split('/').filter(Boolean);
  return parts.length > 0 ? `/${parts[0]}/` : '/';
}

const baseTemp = {
  base: '/Ginkgo.jl/dev/',// TODO: replace this in makedocs!
}

const navTemp = {
  nav: [
{ text: 'Home', link: '/index' },
{ text: 'Concepts', collapsed: false, items: [
{ text: 'Executor', link: '/concepts/executor' }]
 },
{ text: 'Programmer Guide', collapsed: false, items: [
{ text: 'Contributing', link: '/programmer-guide/CONTRIBUTING' },
{ text: 'Use Ginkgo in Julia', link: '/programmer-guide/use-ginkgo-in-julia' },
{ text: 'Ginkgo C Library API', link: '/programmer-guide/ginkgo-c-library-api' },
{ text: 'Debugging Tipps', link: '/programmer-guide/debugging' }]
 },
{ text: 'Reference', collapsed: false, items: [
{ text: 'Ginkgo.jl API', link: '/reference/ginkgo-api' },
{ text: 'GkoPreferences', link: '/reference/ginkgo-preferences' },
{ text: 'Low-level API', link: '/reference/low-level-api' }]
 },
{ text: 'Performance', link: '/performance' },
{ text: 'Index', link: '/reindex' }
]
,
}

const nav = [
  ...navTemp.nav,
  {
    component: 'VersionPicker'
  }
]

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/Ginkgo.jl/dev/',// TODO: replace this in makedocs!
  title: 'Ginkgo.jl',
  description: 'Documentation for Ginkgo.jl',
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../1', // This is required for MarkdownVitepress to work correctly...
  head: [
    ['link', { rel: 'icon', href: `${baseTemp.base}favicon.ico` }],
    ['script', {src: `${getBaseRepository(baseTemp.base)}versions.js`}],
    // ['script', {src: '/versions.js'], for custom domains, I guess if deploy_url is available.
    ['script', {src: `${baseTemp.base}siteinfo.js`}]
  ],
  ignoreDeadLinks: true,
  vite: {
    optimizeDeps: {
      exclude: [
        '@nolebase/vitepress-plugin-enhanced-readabilities/client',
        'vitepress',
        '@nolebase/ui',
      ],
    },
    ssr: {
      noExternal: [
        // If there are other packages that need to be processed by Vite, you can add them here.
        '@nolebase/vitepress-plugin-enhanced-readabilities',
        '@nolebase/ui',
      ],
    },
  },
  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24},
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "C++ Documentation", link: "https://ginkgo-project.github.io/" },
      { text: "Ginkgo.jl API", link: "/reference/ginkgo-api" },
    ],
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Concepts', collapsed: false, items: [
{ text: 'Executor', link: '/concepts/executor' }]
 },
{ text: 'Programmer Guide', collapsed: false, items: [
{ text: 'Contributing', link: '/programmer-guide/CONTRIBUTING' },
{ text: 'Use Ginkgo in Julia', link: '/programmer-guide/use-ginkgo-in-julia' },
{ text: 'Ginkgo C Library API', link: '/programmer-guide/ginkgo-c-library-api' },
{ text: 'Debugging Tipps', link: '/programmer-guide/debugging' }]
 },
{ text: 'Reference', collapsed: false, items: [
{ text: 'Ginkgo.jl API', link: '/reference/ginkgo-api' },
{ text: 'GkoPreferences', link: '/reference/ginkgo-preferences' },
{ text: 'Low-level API', link: '/reference/low-level-api' }]
 },
{ text: 'Performance', link: '/performance' },
{ text: 'Index', link: '/reindex' }
]
,
    editLink: { pattern: "https://github.com/youwuyou/Ginkgo.jl/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/youwuyou/Ginkgo.jl' },
      { icon: 'slack', link: 'https://julialang.org/slack/' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()} ⋅ The Ginkgo Development Team.`
    }
  }
})
