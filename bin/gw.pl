#!/usr/bin/env perl

use Carp;
use Data::Dump qw/dump/;
use DDP;
use Git::Wrapper;
use Modern::Perl;


my $git = Git::Wrapper->new('.');

my $command = $ARGV[0];

croak "Must supply a command." unless $command;

my @git_output = $git->RUN($command);

foreach (@git_output) { say $_; }

