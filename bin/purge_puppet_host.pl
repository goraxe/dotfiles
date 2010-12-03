#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  purge_puppet_host.pl
#
#        USAGE:  ./purge_puppet_host.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      COMPANY:  Sophos
#      VERSION:  1.0
#      CREATED:  16/11/10 22:23:53 GMT
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


use DBI;

my $dbh;

sub db_connect {

    if ( not defined($dbh)) {
        $dbh = DBI->connect("DBI:mysql:hostname=puppetdb-dev.yellow.sophos;database=puppet", "puppet", "puppet-devjazz")
            or die "Could not connect to db: " . $DBI::errstr;
    }

    return $dbh;
}

sub usage {
    print <<EOT;
$0: <hostname list>
    This program will remove a host name and its resources tags from the puppet db
EOT
exit 0;
}

sub delete_host {
    my ($str_host) = @_;

    my $dbh = db_connect();

#    my $sth_host_id = $dbh
    my ($host_id)  = $dbh->selectrow_array("select id from hosts where name = ?", {}, $str_host);

    die "host not found" unless $host_id;
    print "deleteing resource tags\n";
    $dbh->do("delete from resource_tags where resource_id in (select id from resources where host_id = ?)", {}, $host_id)
        or die "could not delete from resource_tags " . $dbh->errstr;

    print "deleteing param_values\n";
    $dbh->do("delete from param_values where resource_id in (select id from resources where host_id = ?)", {}, $host_id)
        or die "could not delete from param_values" . $dbh->errstr;

    print "deleteing resources\n";
    $dbh->do("delete from resources where host_id = ?", {}, $host_id)
        or die "could not delete from resources  " . $dbh->errstr;

    print "deleteing fact_values\n";
    $dbh->do("delete from fact_values where host_id = ?", {}, $host_id)
        or die "could not delete from fact_values" . $dbh->errstr;

    print "deleteing hosts\n";
    $dbh->do("delete from hosts where id = ?", {}, $host_id)
        or die "could not delete from hosts" . $dbh->errstr;
}

usage() if (@ARGV == 0);

foreach my $str_host (@ARGV) {
    delete_host($str_host);
}
