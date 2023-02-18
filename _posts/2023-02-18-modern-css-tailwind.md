---
layout: post
title: Modern CSS with Tailwind
published: no
tags:
  - CSS
  - Tailwind
  - Book
---
Notes from [Modern CSS with Tailwind, Second Edition by Noel Rappin][1] book.

Just In Time (JIT) engine was added to Tailwind 3.0 that builds actual CSS from classes actually used that allows for arbitrary values, more modifiers, and more flexible color palettes. I've started using Tailwind quite recently, so I am not familiar with previous process, but now have more insight into the step-by-step design of the framework.

This is how to define our own classes using `@apply` directive

```css
@layer components {
  .title { @apply text-6xl font-bold }
  .subtitle { @apply text-4xl font-semibold }
  .subsubtitle { @apply text-lg font-medium italic }
}
```

Using of `@layer` allows us to put those new classes into specific component, in this case into section for `components`, which is defined before other Tailwind utilities. This allows us to override them in the html like

```html
<div class="title text-5xl">Title</div>
```

## Typography

page 33


[1]: https://pragprog.com/titles/tailwind2/modern-css-with-tailwind-second-edition/
