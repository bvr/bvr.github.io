---
layout: post
title: Responsive design
published: yes
tags:
  - html
  - css
  - tailwind
  - responsive
---
Notes about [Tailwind][1] responsive features and how to build web site working nicely on all screen sizes from this video:

<iframe width="560" height="315" src="https://www.youtube.com/embed/hX1zUdj4Dw4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

 - there is five breakpoints: `sm` (640px), `md` (768px), `lg` (1024px), `xl` (1280px), `2xl` (1536px). 
 - `max-w-md` and `mx-auto` classes for centered block with specified maximum width
 - the prefix can specify the class would apply when we are over the breakpoint size
 - utilities `h` and `w` for height and width
 - `object-cover` and `object-center` to keep aspect ratio of the image and cover parts of image outside boundaries
 - idea to duplicate some contents and make it `hidden` on some breakpoints
 - using `grid` with `grid-cols-2` to set image next to the text. When using more columns, `col-span-nn` can put the block over multiple columns
 - nice way to visualize blocks using `bg-color-nnn`, especially in combination with breakpoints. [Color palette][2]
 - `<br>` elements can be `hidden`

It is good to see thinking and workflow on how to define the layout for various screen sizes.
 
[1]: https://tailwindcss.com
[2]: https://tailwindcss.com/docs/customizing-colors