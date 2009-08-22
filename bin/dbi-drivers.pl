#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  dbi-drivers.pl
#
#        USAGE:  ./dbi-drivers.pl 
#
#  DESCRIPTION:  shows the installed dbi-drivers
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      COMPANY:  Sophos
#      VERSION:  1.0
#      CREATED:  11/06/09 01:38:54 BST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


use DBI;
{
my %drivers = DBI->installed_drivers();

print "displaying installed drivers\n";
foreach (keys %drivers) {
	print "$_\n";
}
}

{

	my @drivers = DBI->available_drivers();
	print "displaying available drivers\n";
	foreach (@drivers) {
		print "$_\n";
	}
}
