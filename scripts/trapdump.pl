#!/usr/bin/perl

my $TRAPFILE = "/uptime4/logs/trapdump.log";
my $host = <STDIN>;	# Read the Hostname - First line of input from STDIN
chomp($host);
my $ip = <STDIN>;	# Read the IP - Second line of input
 chomp($ip);

while(<STDIN>) {
        chomp($_);
        push(@vars,$_);
}

open(TRAPFILE, ">> $TRAPFILE");
$date = `date`;
chomp($date);
print(TRAPFILE "New trap received: $date for $OID\n\nHOST: $host\nIP: $ip\n");
foreach(@vars) {
        print(TRAPFILE "TRAP: $_\n");
}
print(TRAPFILE "\n----------\n");
close(TRAPFILE);
