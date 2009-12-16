#!/usr/bin/perl

use strict;
use warnings;

# Modules 
use LWP::UserAgent;
use File::Temp qw/ tempdir /;
use File::Copy;
use DateTime::Duration;
use DateTime::Format::Strptime;
use DateTime;
use DBI;

use Data::Dumper;


# Init 

my $debug = 1;

my $tmpdir = $ENV{'TMPDIR'};
$tmpdir ||= "/tmp";
my $TmpTemplate = "AutoHIPPSXXXX";
#my $PostUrl = "http://labreport-dev/test.html";
my $PostUrl = "http://clustermc1.yellow.sophos/cluster/resshieldmal/createjob.pl";
my $FilesURL = "http://sofa/getfile/";
my $SvnRulesFile = "svn://svn/misc/resshield";
my $RulesDir = "/home/goraxe/resshield";
my $RulesFile = "$RulesDir/HIPSRules-1-0-0.bdl";
my $zipStore = "/home/goraxe/zips/";

my $dsn = "DBI:ODBC:database=scanners;driver=FreeTDS;server=uk-virussql1.yellow.sophos;UID=perlscanners;PWD=5r3Nnac5";

my $priority = 4;

# create a formater object so were sql safe
my $formatter = DateTime::Format::Strptime->new(
	pattern => "%d-%b-%Y",
	locale => "en_US");

# figure out where we are in time
my $dtStart = DateTime->now;
$dtStart->set_formatter($formatter);

my $dtEnd;

# Last Monday
$dtStart =  $dtStart - DateTime::Duration->new ( days => 7 + $dtStart->dow_0);
# Last Sunday
$dtEnd = $dtStart + DateTime::Duration->new(days => 6);


# Funcs

sub connectDB {
	my $dbh = DBI->connect($dsn);
	return $dbh;
}



sub getFiles {
	my $ua = shift;
	my $priority = shift;
	my $dtStart = shift;
	my $dtEnd = shift;
	my $dbh = connectDB || die "could not connect to db $DBI::errstr";
	my $sth = $dbh->prepare("{call stoShasNotDetected ( ?, ?, ? ) }");
	my $shas;

	$sth->execute($priority, "$dtStart", "$dtEnd");
	$shas = $sth->fetchall_arrayref;

	my $tmpdir = tempdir ($TmpTemplate);

	print "TMPDIR: $tmpdir\n" if (defined ($debug));

	foreach my $row (@$shas) {
		my $sha = @$row[0];
		print "RETIVING: $FilesURL$sha\n" if (defined ($debug));
		my $response = $ua->get($FilesURL . $sha);

		if ($response->is_success) {
		
		open FH, ">", $tmpdir . "/" . $sha or die "could not open $tmpdir/$sha for writting\n";
		print FH $response->content;
		close FH;
		}
	}
	my $zip = "pri_$priority-$dtStart-$dtEnd.zip";
	system ("zip", "-rDjm", $zip, "$tmpdir");
	move $zip, $zipStore;
	unlink $tmpdir;
	return $zipStore . $zip;
}

sub submitJob {
	my $ua = shift;
#	my $Rulesfile = shift;
	my $SampleFile = shift;
my $url;

# get the rules file

system ("svn", "co", $SvnRulesFile, "$RulesDir");

# post the request
my $response = $ua->post( $PostUrl,
		[ 'jobname' => 'pri4',
			'owner' => 'autoHIPS',
			'priority' => 'Low',
			'rules' => [$RulesFile],
			'zip' => [$SampleFile],
			'submit' => 'submit'
		],
		Content_Type => "multipart/form-data",
		);
# if we need to do anything with the content, job id
# then  <a href="jobinfo.pl?id=2439974"> would be a good thing
# to regex on
#print Dumper $response->content;


}

# Main

die "$RulesDir does not exist" if ( ! -e $RulesDir );
die "$RulesDir is not a directory " if ( ! -d  $RulesDir );

#connectDB;

my $ua = LWP::UserAgent->new;

#my $file = getFiles $ua, $priority, $dtStart, $dtEnd;
my $file = "/home/goraxe/test.zip";
submitJob $ua, $file;
