#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  update_log.pl
#
#        USAGE:  ./update_log.pl 
#
#  DESCRIPTION:  logs all hosts runing update statments
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      COMPANY:  Sophos
#      VERSION:  1.0
#      CREATED:  11/01/10 13:26:58 GMT
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


use DBI;
use Data::Dumper;

my $dbh = DBI->connect("DBI:mysql:","root", "jazz");


$| = 1;

while (1) {
	my $res = $dbh->selectall_arrayref("SHOW FULL PROCESSLIST", {Slice => {} } );

#	system "clear";
#	print Dumper pop @$res;
	my @updates = grep {$_->{Info} =~ m/INTERVAL/ } grep { $_->{Info} =~ m/UPDATE/ } grep { defined $_->{Info} } @$res;

#	my @updates =grep { $_->{Info} =~ m/UPDATE/ } grep { defined $_->{Info} } @$res;
#	print Dumper \@updates;
	my $date = localtime();
	foreach my $q (@updates) {
		print "$date: $q->{Host}: $q->{Info}\n";
	}
	sleep 1;
}


