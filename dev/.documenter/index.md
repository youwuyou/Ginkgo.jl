---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: Ginkgo.jl Docs
  text: Julia bindings for the Ginkgo linear algebra library
  tagline: High-performance sparse linear algebra with a flexible backend choice for manycore systems in Julia.
  actions:
    - theme: brand
      text: Getting Started
      link: /concepts/executor
    - theme: alt
      text: API Reference 📚
      link: /reference/ginkgo-api
    - theme: alt
      text: View on GitHub
      link: https://github.com/youwuyou/Ginkgo.jl
  image:
    src: /assets/logo.png
    alt: Ginkgo.jl

features:
  - icon: ⚙️
    title: Multi-backend Executors
    details: Run on CPUs, NVIDIA GPUs (CUDA), AMD GPUs (HIP), and Intel GPUs (SYCL) using Ginkgo’s executors.
    link: /concepts/executor

  - icon: 🚀
    title: High-performance Solvers
    details: Use high-performance sparse iterative and direct solvers with a variety of preconditioners via a Julian interface.
    link: /reference/ginkgo-api

  - icon: 🔀
    title: Switchable Binaries
    details: Choose and configure different Ginkgo binary builds.
    link: /reference/ginkgo-preferences

  - icon: 🧰
    title: Low-level API
    details: Direct access to Ginkgo’s C++ API for fine-grained control when you need it.
    link: /reference/low-level-api
---

