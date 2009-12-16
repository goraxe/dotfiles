#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  dump_tables.pl
#
#        USAGE:  ./dump_tables.pl 
#
#  DESCRIPTION:  extract some data from the scanners db
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      COMPANY:  Sophos
#      VERSION:  1.0
#      CREATED:  28/10/09 10:54:49 GMT
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use DBI;
use Getopt::Long;
use YAML::Any;
use Data::Dump qw(dump);
use constant  {
	DEFAULT_DSN			=> "dbi:mysql:hostname=scannersdb-read.yellow.sophos;database=Scanners2",
	DEFAULT_USER		=> 'Scanners2',
	DEFAULT_PASSWORD	=> '5canner2',
	DEFAULT_LIMIT		=> 10,
};


my $opts_spec = ["help|?|h", "tables|t=s@", "dsn|d=s", "user|u=s", "password|pass|p=s", "limit|l=i", "where=s"];

my $opts = {};

GetOptions($opts, @$opts_spec);



#my ($opts, $usage) = get_options(
sanitize_options($opts);
my $dbh = db_connect($opts);
foreach my $table (@{$opts->{tables}}) {
	open my $fh, ">", $table;
	my $data = get_data($opts, $table);
	print dump $data;
	print $fh dump $data;
	close $fh;
	print "\n";
}

sub sanitize_options {
	my $opts = shift;

	$opts->{dsn}		||= DEFAULT_DSN;
	$opts->{user}		||= DEFAULT_USER;
	$opts->{password}	||= DEFAULT_PASSWORD;
	$opts->{limit}		||= DEFAULT_LIMIT;
	$opts->{tables}		||= get_tables($opts);

}

sub db_connect {
	my $opts = shift;
	my $dsn = $opts->{dsn};
	my $user = $opts->{user};
	my $pass = $opts->{password};

	my $dbh = DBI->connect_cached($dsn,$user,$pass)
		or die "could not connect to database $@";

	return $dbh;
}


sub get_tables {
	my $opts = shift;
	my $dbh = db_connect($opts);

	my $tables = $dbh->selectall_arrayref("show tables")
		or die "Could not fetch tables: $@";
	$tables = ([map { $_->[0] } @$tables]);
	print dump $tables;
	return $tables;
}


sub get_data {
	my ($opts, $table)  = @_;
	my $dbh = db_connect($opts);
	my $data = $dbh->selectall_arrayref("select * from $table " .
		($opts->{where} ? "where ". $opts->{where} : "") .
		" limit " . $opts->{limit}, { Slice => {} }) ;
	return $data;
}
