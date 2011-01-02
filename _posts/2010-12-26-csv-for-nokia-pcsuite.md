---
layout: post
title: Addressbook migration to Nokia
category: perl
perex: >
  This christmas I finally decided to upgrade my venerable cell phone to something
  newer. Old one, Siemens ME45, served me well for eight years, but its second 
  battery life is close to death and I got feeling new gizmo would be nice.  
tags:
  - perl
  - Nokia PC Suite
  - unicode
  - csv
  - Text::CSV_XS
  - BOM
---
I ended up buying 
[Nokia 6303i][n6303].
This is simple script to help me convert addressbook into new device.

The old Siemens came with serial RS232 data cable and I have small program to 
backup data from phone into text file. Addressbook in particular is simple 
comma-separated (CSV) file. First column is either '''SM''' (SIM card) 
or '''AD''' (Address book). Second column is entry number. Remainder are 
properties of the contact:

    ....
    SM;009;+420776123456;"Sam"
    SM;010;+420604234567;"Falco"
    AD;0;Magda;;+420777345678;;;;;;;;;;;
    AD;1;Jerry;;+420777456789;;;;;;;;;;;VIP
    ....

Nokia comes with [PC Suite][pc_suite] that allows to import utf-16 encoded
55-column CSV. Exact format I got by exporting one hand-made entry into file.
The `@me45_into_col` mapping array gives for each column from Siemens format 
specific column in Nokia one.

The most tricky part was to encode output file properly and add correct 
[BOM][bom] (byte-order mark) to the start of file. These two lines do the job:

{% highlight perl %}
open my $nokia_out, ">:raw:encoding(utf-16le):utf8", $ARGV[1] or die;
print {$nokia_out} "\x{FEFF}";
{% endhighlight %}

First is opening file that is encoding internal perl **utf-8** into **utf-16 
little endian**. The second line writes single letter - two bytes: `0xFE`, `0xFF` - 
into the beginning of file to indicate encoding. All [BOM][bom]s defined are:

  - `0x00 0x00 0xFE 0xFF` ... utf-32, big-endian
  - `0xFF 0xFE 0x00 0x00` ... utf-32, little-endian
  - `0xFE 0xFF          ` ... utf-16, big-endian
  - `0xFF 0xFE          ` ... utf-16, little-endian
  - `0xEF 0xBB 0xBF     ` ... utf-8

Script can be called as:

{% highlight bash %}
perl convert_list.pl siemens.csv nokia.csv
{% endhighlight %}

## convert_list.pl

{% highlight perl %}
use strict;
use utf8;
use Text::CSV_XS;

# mapping of Siemens columns to Nokia columns
my @me45_into_col = (
    undef,
    undef,
    3,       # Last Name
    1,       # First Name
    13,      # Phone
    6,       # Company
    22,      # Street
    24,      # City
    23,      # Postcode
    26,      # Country
    14,      # Tel Office
    27,      # Tel Mobile
    16,      # Fax
    15,      # E-Mail
    18,      # Web Page
    undef,   # Group
);

my @nokia_header = (
    # ... entries copied from exported CSV file
);

die "error: two files expected as input\n"
  . "syntax: $0 infile outfile\n"
    unless @ARGV == 2;

open my $me45_in,   "<", $ARGV[0] or die;

# prepare output file with BOM
open my $nokia_out, ">:raw:encoding(utf-16le):utf8", $ARGV[1] or die;
print {$nokia_out} "\x{FEFF}";

# CSV header
my $csv = Text::CSV_XS->new({ binary => 1, sep_char => ';' });
if($csv->combine(@nokia_header)) {
    print {$nokia_out} $csv->string,"\n";
}

# data
while(<$me45_in>) {
    unless($csv->parse($_)) {
        warn "Bad formatting: $_";
        next;
    }
    my @me45_fields = $csv->fields;

    next if $me45_fields[0] ne "AD";

    my @out = (undef) x @nokia_header;
    for(my $i = 0; $i < @me45_into_col; $i++) {
        next unless defined $me45_into_col[$i];
        $out[$me45_into_col[$i]] = $me45_fields[$i];
    }

    unless($csv->combine(@out)) {
        warn "Bad data: @out";
        next;
    }
    print {$nokia_out} $csv->string,"\n";
}
{% endhighlight %}

[n6303]:    http://europe.nokia.com/find-products/devices/nokia-6303i-classic
[pc_suite]: http://europe.nokia.com/support/download-software/pc-suites
[bom]:      http://www.unicode.org/faq/utf_bom.html#BOM
