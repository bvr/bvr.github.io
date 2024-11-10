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
I was recently parsing some data with perl regexes. Each match provided number of found items that I needed to extract. The problem was slightly different, but say we have following input and a variable:

```
id: 1   label: Button
id: 2   label: Radiobutton
id: 3   label: Checkbox
```

If I want to create mapping between label and the id, I can use something like this:

```perl
my %label_to_id = ();
while($items =~ /id: \s* (?<id>\d+) \s+ label: \s* (?<label>.*?)$/gmx) {
    $label_to_id{ $+{label} } = $+{id};
}
```

The regex is pretty straightforward. For better readability it uses `x` modifier that allows us to put in whitespace and even comments. The spacing then needs to be explicitly written as you can see with `\s*` entries.

The captures can be done with parenthesis and address them with `$1` and `$2` variables, but here we use named capture with `(?<name> ...)`. All results are then available in `%+` hash. 

Last thing worth noting is `g` modifier. It tries to find all matches, so we can iterate over them with `while` and store every match. 

When we dump the `%label_to_id` contents, we get following as expected:

```perl
{ Button => 1, Checkbox => 3, Radiobutton => 2 }
```
