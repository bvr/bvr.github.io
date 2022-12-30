---
layout: post
title: Using YAML for config files
published: yes
tags:
  - perl
  - configuration
  - yaml
  - YAML::XS
  - Data::Dump
---
When it comes to configuration of a program, my preference is structured config file that directly translates into a programming language structures. I've grown to like [YAML][1], as it allows easy comments, verbatim blocks, associations or arrays.

For instance

```yaml
---
output:
  - target\directory\output.html

year: 2022
threshold_percent: 3
colors:
  - '#5B9BD5'
  - '#ED7D31'
  - '#FF0000'
  - '#FFC000'
  - '#FF33CC'
  - '#70AD47'
  - '#255E91'
  - '#7030A0'

preamble: |
  This is longer paragraph with many useful information.
  And it continues here ...
```

Here is the way to load it and dump its structures out

```perl
use YAML::XS qw(LoadFile);
use Data::Dump qw(dd);

my $config_name = 'config.yaml';
my $config = LoadFile($config_name);

dd $config;
print "First color: " . $config->{colors}[0];
```

yields

```perl
{
  colors => [
    "#5B9BD5",
    "#ED7D31",
    "#FF0000",
    "#FFC000",
    "#FF33CC",
    "#70AD47",
    "#255E91",
    "#7030A0",
  ],
  output => ["target\\directory\\output.html"],
  preamble => "This is longer paragraph with many useful information.\nAnd it continues here ...\n",
  threshold_percent => 3,
  year => 2022,
}
First color: #5B9BD5
```

[1]: https://yaml.org/
