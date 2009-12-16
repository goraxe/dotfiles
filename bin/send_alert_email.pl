#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  send_alert_email.pl
#
#        USAGE:  ./send_alert_email.pl 
#
#  DESCRIPTION:  manually send an alert email
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  11/22/08 10:30:56 GMT
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


use Sophos::VirusLab::GetFile qw(getfile);
use MIME::Entity;

#################################################################################
#								MAIN
#################################################################################

print "Args = ". @ARGV . "\n";
usage() if ( @ARGV != 2 );

my $file_sha = shift;
my $file_name = shift;

sub usage {
print <<EOT
$0: <pgp_sha> <pgp_filename>
	will retrieve a pgp file from the filesdb and send it out to the alerts list
EOT
;
	exit 0;
}


my (undef, $r) = getfile($file_sha, $file_name);

if ( $r->is_success) {
	my @recpients = SendEmail (file_name  => $file_name, file_path=> $file_name);
	if (@recpients == 0) {
		print "failed to send\n";
	} else {
		print "sent email to: ". join @recpients, ", ";
	}
} else {
	print "failed to retrieve file\n";
	print $r->content;
	exit -1;
}


sub SendEmail {
	my $opts = { @_ };
	my $file_name = $opts->{file_name};
	my $file_path = $opts->{file_path};
# grab from config in the end
my $mail_config = {
	from => 'viruslab@sophos.com',
	to => 'alerts@sophos.com',
	subject => 'Sophos Samples',
	host => "uk-virusapp4.yellow.sophos",
};

	$ENV{MAILADDRESS} = $mail_config->{from};
	my $msg = MIME::Entity->build(
		From => $mail_config->{from},
		To => 'alerts@sophos.com', # $opts->{To} || $mail_config->{to},
		Bcc => 'Gordon.irving@sophos.com, ' .  $opts->{Bcc} || $mail_config->{bcc},
		Subject => $opts->{Subject} || $mail_config->{subject},
		Type => 'multipart/mixed',
#		Data => '',
	);

	if (defined $opts->{body}) {
		$msg->attach(
			Type => 'text/plain',
			Disposition => 'inline',
			Data => $opts->{body},
		);
	}
	
	if (defined $file_path) {
		$msg->attach(
			Path => $file_path,
			Filename => $file_name,
			Disposition => 'attachment',
			Type => 'application/pgp',
			Encoding => 'base64',
		);
	}

	$msg->smtpsend( MailFrom=> $mail_config->{From}, Host=> $mail_config->{host} );

}
