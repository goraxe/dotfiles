#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  display_cache.pl
#
#        USAGE:  ./display_cache.pl 
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
#      CREATED:  18/09/09 14:31:05 BST
#     REVISION:  ---
#===============================================================================


use FindBin qw($Bin);
use File::Spec::Functions qw(catdir);
use Cwd qw(realpath);


use Cache::FileCache;

use lib catdir($Bin, "..", "lib");
use Data::Dumper;



use Getopt::Long;

my $opts = { };

GetOptions($opts, "cache=s", "namespace=s", "keys=s@");

my $cache =  Cache::FileCache->new(); 
if ($opts->{cache}) {
	print "setting cache\n";
	$cache->set_cache_root($opts->{cache});
}
print "displaying namespaces\n";
print (join "\n", map { "\t$_" } @{$cache->get_namespaces}) ."\n";
if ($opts->{namespace}) {
	print "setting namespace ". $opts->{namespace} ."\n";
	$cache->set_namespace($opts->{namespace});
} 

print "getting list of keys\n";
print (join "\n", map { "\t$_" } @{$cache->get_keys()})."\n";

print "displaying requested keys\n";

foreach my $key (@{$opts->{keys}}) {
	print "$key = " . Dumper $cache->get($key);
}
