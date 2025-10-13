---
layout: post
title: Perl data into JSON and YAML
published: yes
tags:
  - perl
  - yaml
  - json
  - trace
  - JSON::XS
---
I needed to build simple perl data structure and provide users formats how they can specify it themselves. The structure looks like this:

```perl
my $data = [
    {   doctype  => 'SRS',
        elements => [
            {   name    => 'srs01.md',
                trace => [
                    {   name => 'SRS_001',
                        tags => {allocation => 'SW'},
                    },
                    {   name => 'SRS_002',
                        tags => {allocation => 'HW'}
                    }
                ]
            }
        ]
    },
    {   doctype  => 'SRD',
        elements => [
            {   name    => 'srd01.md',
                trace => [
                    {   name   => 'SRD_001',
                        source => 'SRS_001',
                    }
                ]
            }
        ]
    }
];
```

It is a list of categories (`doctype`) with elements related to them. Each element contains tracing in form of textual anchors like `SRS_001` and connection between them via `source` tag.

Here is simple code to emit it into a JSON file:

```perl
use JSON::XS;

my $json_coder = JSON::XS->new->ascii->pretty->canonical;
print $json_coder->encode($data);
```

The coder is setup to be output ASCII output (`ascii`), nicely format it (`pretty`) and sort keys (`canonical`) in hashes to have stable output. The result is like this:

```json
[
   {
      "doctype" : "SRS",
      "elements" : [
         {
            "name" : "srs01.md",
            "trace" : [
               {
                  "name" : "SRS_001",
                  "tags" : {
                     "allocation" : "SW"
                  }
               },
               {
                  "name" : "SRS_002",
                  "tags" : {
                     "allocation" : "HW"
                  }
               }
            ]
         }
      ]
   },
   {
      "doctype" : "SRD",
      "elements" : [
         {
            "name" : "srd01.md",
            "trace" : [
               {
                  "name" : "SRD_001",
                  "source" : "SRS_001"
               }
            ]
         }
      ]
   }
]
```

Other option is to use [YAML][1]:

```perl
use YAML;

print YAML::Dump($data);
```

The result is somewhat more concise and nicer, perhaps:

```yaml
---
- doctype: SRS
  elements:
    - name: srs01.md
      trace:
        - name: SRS_001
          tags:
            allocation: SW
        - name: SRS_002
          tags:
            allocation: HW
- doctype: SRD
  elements:
    - name: srd01.md
      trace:
        - name: SRD_001
          source: SRS_001
```

[1]: https://yaml.org/