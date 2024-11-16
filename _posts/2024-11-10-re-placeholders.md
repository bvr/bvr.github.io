---
layout: post
title: Regex placeholders
published: yes
tags:
  - perl
  - regex
  - placeholder
  - hash
---
Recently, I worked on parsing data using Perl regexes. The task involved extracting specific information from matches. Here's an example scenario:

```
id: 1   label: Button
id: 2   label: Radiobutton
id: 3   label: Checkbox
```

The goal was to create a mapping between `label` and `id`. Solution can look like this:

```perl
my %label_to_id = ();
while($items =~ /id: \s* (?<id>\d+) \s+ label: \s* (?<label>.*?)$/gmx) {
    $label_to_id{ $+{label} } = $+{id};
}
```

The regex is pretty straightforward, but few bits are worth explanation.

 1. **Regex Details**:
   - The `x` modifier enhances readability by allowing whitespace and comments in the regex.
   - Explicit whitespace (`\s*`) is required where necessary.
   - Named captures (`(?<name> ...)`) store matched values in the `%+` hash for easy access.

2. **Match Iteration**:
   - The `g` modifier finds all matches, enabling iteration with `while` to process each match.

3. **Named Captures vs Positional**:
   - Named captures (`$+{name}`) are clearer than positional captures (`$1`, `$2`), especially in complex patterns.

When dumping `%label_to_id`, we get the expected output:

```perl
{ Button => 1, Checkbox => 3, Radiobutton => 2 }
```
