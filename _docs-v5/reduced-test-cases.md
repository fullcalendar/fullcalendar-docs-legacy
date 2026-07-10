---
title: Reduced Test Cases
description: How to create a simplified, reproducible demonstration of a bug
layout: docs-article
assets: [ 'demo-to-codepen.css', 'demo-to-codepen.js' ]
codepen_templates:
  - label: Standard
    demo_url: /v5/initialize-globals-demo
    feed_demo_url: /v5/debug-json-feed
  - label: Premium plugins
    demo_url: /v5/debug-scheduler
    feed_demo_url: /v5/debug-scheduler-json-feed
framework_examples:
  - examples:
      - label: React
        url: https://stackblitz.com/github/fullcalendar/fullcalendar-examples/tree/v5/react
  - examples:
      - label: Vue 3
        url: https://stackblitz.com/github/fullcalendar/fullcalendar-examples/tree/v5/vue3-typescript
      - label: '2'
        url: https://stackblitz.com/github/fullcalendar/fullcalendar-examples/tree/v5/vue2
  - brave_note: true
    examples:
      - label: Angular 12
        url: https://stackblitz.com/github/fullcalendar/fullcalendar-examples/tree/v5/angular12
---

{% include reduced-test-cases.html %}
