---
layout: post
title: jekyll and TailwindCSS
published: yes
tags:
  - jekyll
  - tailwind
  - css
  - html
---
In now about [12 years old article][1] there are some notes how to make jekyll working on my local Windows computer.

I was recently working on a site redesign using [Tailwind CSS framework][2]. 

## Installation

From [Tailwind installation guide][3] ...

The commands for installation and rebuilding the css is 

```
npm install tailwindcss
npm install @tailwindcss/typography
npm install @tailwindcss/line-clamp
npx tailwindcss -i css\tailwind.css -o css\output.css --watch
```

## [Utility first][4] - basic concepts

> Building complex components from a constrained set of primitive utilities

In essence it provides common classes for most CSS features with predefined values for sizes and colors. The generator mentioned above then pick just those used, so resulting CSS for production site is rather small.

There is pretty good summary in [Tailwind Cheat Sheet][5].

## Some inspiration webs

 - [Flotiq Gatsby Blog](https://github.com/flotiq/flotiq-gatsby-blog-2) - [live demo](https://flotiqgatsbyblog2.gatsbyjs.io/)
 - [Digital Garden theme for Hugo](https://github.com/apvarun/digital-garden-hugo-theme) - [live demo](https://digital-garden-hugo-theme.vercel.app/)
 - [Chirpy Jekyll Theme](https://github.com/cotes2020/jekyll-theme-chirpy/) - [live demo](https://chirpy.cotes.page/)


[1]: {% post_url 2010-10-14-local-jekyll %}
[2]: https://tailwindcss.com
[3]: https://tailwindcss.com/docs/installation
[4]: https://tailwindcss.com/docs/utility-first
[5]: https://nerdcave.com/tailwind-cheat-sheet
