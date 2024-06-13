---
layout: post
title: Modular Monolith
published: no
tags:
  - something
---
My notes from listening to this youtube video by Steve Smith.

<div class="aspect-w-16 aspect-h-9">
<iframe src="https://www.youtube.com/embed/VnIWtVdbwTg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

[Getting Started: Modular Monoliths in .NET](https://bit.ly/3T1pC17)

## Software Architecture

Monolith basically means that there is a single distribution as the outcome of the project.

Inside, it usually uses some kind of layered architecture, with layers like:

 - UI
 - Business Logic
 - Data Layer
 - Database or External Services

There is good separation between layers, but there is no modularity on the functionality, so this can be quite difficult to test. It is possible to enforce modularity with microservices, but this on the other hand is quite costly.

 - [MediatR](https://github.com/jbogard/MediatR)
 - app.FastEndpoints().UseSwaggerGen()
 - 