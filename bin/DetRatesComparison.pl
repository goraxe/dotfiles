use strict;
use warnings;

use DBI;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Strptime;
use Data::Dumper;

my $dbh = DBI->connect("DBI:ODBC:database=scanners;driver=FreeTDS;server=uk-virussql1.yellow.sophos;UID=perlscanners;PWD=5r3Nnac5");

my $sth = $dbh->prepare("{call stoReportDetectionRates2 ( ?, ?, ?) }");

my $formatter = DateTime::Format::Strptime->new(
	pattern => "%d-%b-%Y",
	locale => "en_US");

my $dtStart = DateTime->new( 
							year	=> 2007,
							month	=> 3,
							day		=> 19,
							hour	=> 0,
							minute	=> 0,
							second	=> 0
						);

$dtStart->set_formatter($formatter);
my $dtFinal = DateTime->new (
							year	=> 2007,
							month	=> 7,
							day		=> 1,
							hour	=> 0,
							minute	=> 0,
							second	=> 0
						);

my $durIteration = DateTime::Duration->new(days=>6);
my $durNext = DateTime::Duration->new(days=>1);


while ($dtStart < $dtFinal) {

my $dtEnd = $dtStart + $durIteration;

	foreach my $pri (3,4) {
		print "Results for pri: $pri, $dtStart , $dtEnd\n";
	$sth->execute($pri, "$dtStart", "$dtEnd");
	my $res = $sth->fetchall_arrayref;
		print Dumper $res;
	}
	$dtStart = $dtEnd + $durNext;
}
