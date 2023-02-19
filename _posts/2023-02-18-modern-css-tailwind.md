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

Text sizes are `xs`, `sm`, `base`, `lg`, `xl`, and number of `2xl`, `3xl` and so on.

Colors are available in 22 flavors, each of them allows levels `50` (lightest), `100`, `200` .. `900` (darkest)

 - Slate, Gray, Zinc, Neutral, Stone
 - Red, Orange, Pink, Rose
 - Amber, Yellow
 - Lime, Green, Emerald, Teal
 - Cyan, Sky, Blue,
 - Indigo, Violet, Purple, Fuchsia

The utility example can be `text-fuchsia-400`. It also provides means for opacity with `text-fuchsia-400/50`.

Alignment and spacing can be set with `text-left`, `text-center`, `text-right`, or `text-justify` for horizontal, `align-baseline`, `align-top`, `align-middle`, or `align-bottom` for vertical. `leading-normal` and friends are for line spacing.

Since the reset in the `base` layer clears out all formatting and everything related to lists, we can add them with `list-disc` and `list-decimal`.

Then there are few plugins mentioned - `typography` and `forms` which can be installed and referenced from the tailwind config file

```js
module.exports = {
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
```

## The Box



[1]: https://pragprog.com/titles/tailwind2/modern-css-with-tailwind-second-edition/
