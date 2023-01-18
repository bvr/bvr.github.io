---
layout: post
title: Generate queries with SQL::Abstract
published: yes
tags:
  - perl
  - SQL
  - SQL::Abstract
  - DBIx::Class
  - DBI
---
Building SQL from data structures is common problem. One solution is using full ORM like [DBIx::Class][1], but if you need something more lightweight, there is nice module [SQL::Abstract][2]. For example

```perl
use SQL::Abstract;

my %data = (
    name => 'Jimbo Bobson',
    phone => '123-456-7890',
    address => '42 Sister Lane',
    city => 'St. Louis',
    state => 'Louisiana',
);
my($stmt, @bind) = $sql->insert('people', \%data);
```

Builds following items

```sql
INSERT INTO people ( address, city, name, phone, state) VALUES ( ?, ?, ?, ?, ? )
```

```perl
( "42 Sister Lane", "St. Louis", "Jimbo Bobson", "123-456-7890", "Louisiana" )
```

The resulting variables can be directly used in [DBI][3] calls, like

```perl
my $sth = $dbh->prepare($stmt);
$sth->execute(@bind);
```

Similar approach works for UPDATE statements, all what is needed is to change `insert` method to `update`. Result is

```sql
UPDATE people SET address = ?, city = ?, name = ?, phone = ?, state = ?
```

```perl
( "42 Sister Lane", "St. Louis", "Jimbo Bobson", "123-456-7890", "Louisiana" )
```

The module get pretty wild with definition of WHERE clauses. The hashref defines AND composition, arrayref produces OR composition. For example

```perl
my($stmt, @bind) = $sql->select('tickets', '*', {
    reporter => 'Roman',
    owner => \@names,
    status => 'closed',
    resolution => [
        { '!=', 'invalid'},
        { '!=', 'wontfix'},
    ],
});
```

Gets all tickets where `Roman` is reporter, owner is from the supplied list that are already close with other resolutions than `invalid` or `wontfix`. The SQL goes like

```sql
SELECT * 
FROM tickets 
WHERE ( ( ( owner = ? OR owner = ? OR owner = ? OR owner = ? ) 
  AND reporter = ? 
  AND ( resolution != ? OR resolution != ? ) 
  AND status = ? ) )
```

Binding values are 

```perl
("Jim", "John", "Joe", "Chuck", "Roman", "invalid", "wontfix", "closed")
```

The module can make your SQL building much easier and actually is used by DBIx::Class to support filtering of resultsets.

[1]: https://metacpan.org/pod/DBIx::Class
[2]: https://metacpan.org/pod/SQL::Abstract
[3]: https://dbi.perl.org/
