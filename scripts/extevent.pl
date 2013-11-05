#!/usr/bin/perl -w

use Getopt::Long;
use LWP::Simple;
use URI::Escape;
use strict;

#
# Command line args are:
# --host: specify the server running up.time
# --port: specify the up.time port on the server (usually 9996)
# --status: New status of the service being monitored.
#        0=OK
#        1=Warning
#        2=Critical
#        3=Unknown
# --message: Human readable diagnostic message
# --monitorName: Name of the monitor
#

#my $host ="10.1.4.59"; #KIRBY
#my $host = "10.1.4.152"; #UPTIME
my $host = "10.15.10.38"; #MEDIAGRIF

my $port = 9996;
my $status ='';
my $message='';
my $name='';

GetOptions('host=s' => \$host,
		   'port=i' => \$port,
		   'status=i' => \$status,
		   'message=s' => \$message,
		   'monitorName=s' => \$name);

if (@ARGV != 0) {
	print STDERR "bad command line args\n";
	print STDERR "Usage: --host=Hostname --port=PortNumber --status=StatusNumber --message=message --monitorName=name";
	exit 1;
}

my %status_name = (
  0 => 'OK',
  1 => 'WARN',
  2 => 'CRIT'
);

my $statusString = $status_name{$status} || 'Unknown';

my $qname = uri_escape($name);
my $qmessage = uri_escape($message);
my $url = "http://$host:$port/command?command=externalcheck&name=$qname&status=$status&message=$qmessage";
get($url);
