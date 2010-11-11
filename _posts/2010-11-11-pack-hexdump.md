---
layout: post
title: Convert hexdump to binary data
category: perl
perex: >
  Working on analysis of network packets I needed to convert data dumped
  in a file to real binary form before processing them further.
tags:
  - perl
  - pack
  - hex
  - split
---
I am using [WireShark](http://www.wireshark.org/) to capture network packets.
Data were dumped WireShark's commandline companion **tshark**:

{% highlight bash %}
tshark -n -T fields -e ip.src -e ip.dst -e data.data -r packet-data.pcap
{% endhighlight %}

The data output has lines with three fields, source IP, destination IP and 
hexdumped data.

    ....
    192.168.0.29  192.168.0.47  10:20:10:40:00:00:04:d4							
    192.168.0.29  192.168.0.47  10:20:10:40:00:00:04:d4							
    192.168.0.29  192.168.0.47  00:00:00:01:00:00:04:00:10:00:00:13:00:00:00:00:00
    192.168.0.29  192.168.0.47  00:00:00:01:00:00:04:00:10:00:00:13:00:00:00:00:00
    ....

Processing of such data is simple in perl, each line we split on tab, then
decode hexdump to binary string by packing individual bytes into one string using 
[pack](http://perldoc.perl.org/functions/pack.html). 

{% highlight perl %}
while(<>) {
    chomp;
    my ($src_ip, $dst_ip, $hexdump) = split /\t/;
    my $data = pack 'C*', map { hex } split /:/, $hexdump;
    
    # process data -- treat it as several 4B big-endian integers
    my ($head, $len, @rest) = unpack 'N*', $data;
}
{% endhighlight %}
