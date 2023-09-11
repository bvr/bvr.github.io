---
layout: post
title: Circular exporting
published: yes
tags:
  - perl
  - module
  - Exporter
---
I was recently looking into a legacy system written in perl and there was a problem with cross-using exported subroutines between the modules. The system uses those to define kind of domain language to execute a sequence of commands. Those come from various modules and it often fail to export symbols properly. 

One colleague found a good solution for the problem in [wisdom of perl monks][1], placing it here as a note for self.

> [ The need to use this technique is a very strong indicator of a design flaw in your system, but I recognize that the resources are not always available to fix design flaws. ]

> If ModA uses ModB, ModB uses ModA, and ModA or ModB imports symbols from the other, one needs to pay attention to code execution order. The best way I've found to avoid problems is to setup Exporter before loading any other module. 

For example

```perl
# ModA.pm

package ModA;

use strict;
use warnings;

use Exporter qw( import );
BEGIN { our @EXPORT = qw( ... ); }

use This;
use ModB;
use That;

...

1;
```

and

```perl
# ModB.pm

package ModB;

use strict;
use warnings;

use Exporter qw( import );
BEGIN { our @EXPORT = qw( ... ); }

use This;
use ModA;
use That;

...

1;
```

[1]: https://www.perlmonks.org/?node_id=778639