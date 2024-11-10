
my $items = <<END;
id: 1   label: Button
id: 2   label: Radiobutton
id: 3   label: Checkbox
END


my %label_to_id = ();
while($items =~ /id: \s* (?<id>\d+) \s+ label: \s* (?<label>.*?)$/gmx) {
    $label_to_id{ $+{label} } = $+{id};
}

use Data::Dump qw(dd);
dd \%label_to_id;