#! /usr/bin/env perl
##
## Search the processes which are listening on the given port.
##
## For SunOS 5.10.
##

use strict;
use warnings;

die "Port missing" unless $#ARGV >= 0;
my $port = int($ARGV[0]);
die "Invalid port" unless $port > 0;

my @pids;
map { push @pids, $_ if $_ > 0; } map { $_ =~ s/\D//g; int($_) if $_ ne ""; } `ls /proc`;

foreach my $pid (@pids) {
    open (PF, "pfiles $pid 2>/dev/null |") 
        || warn "Can not read pfiles $pid";
    $_ = <PF>;
    my $fd;
    my $type;
    my $sockname;
    my $peername;
    my $report = sub {
        if (defined $fd) {
            if (defined $sockname && ! defined $peername) {
                print "$pid $type $sockname\n"; } } };
    while (<PF>) {
        if (/^\s*(\d+):.*$/) {
            &$report();
            $fd = int ($1);
            undef $type;
            undef $sockname;
            undef $peername; }
        elsif (/(SOCK_DGRAM|SOCK_STREAM)/) { $type = $1; }
        elsif (/sockname: AF_INET[6]? (.*)  port: $port/) {
            $sockname = $1; }
        elsif (/peername: AF_INET/) { $peername = 1; } }
    &$report();
    close (PF); }


