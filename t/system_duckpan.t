#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Script::Run;
use File::Temp qw/ tempdir /;
use IO::All;
use Path::Class;

use App::DuckPAN;

my $version = $App::DuckPAN::VERSION;

{
	my ( $return, $out, $err ) = run_script( 'duckpan', [] );

	like($out,qr/DuckPAN/, 'DuckPAN without arguments gives out usage');
	# like($out,qr/$version/, 'DuckPAN man page gives out right version');

	is($err,"",'DuckPAN gives out nothing on STDERR');
	is($return,1,'DuckPAN gives back exit code 1');
}

{
	my $tempdir = tempdir( CLEANUP => 1 );
	$ENV{DUCKPAN_CONFIG_PATH} = "$tempdir";

	run_ok( 'duckpan', [qw( env test me )], 'setting DuckPAN env test to me');

	is(io(file($tempdir,'env.ini'))->slurp,"TEST = me\n",'checking content of env.ini');

	my ( undef, $getenvout, $getenverr ) = run_script( 'duckpan', [qw( env test )]);

	like($getenvout,qr/TEST='me'/,'getting test env from DuckPAN');
	is($getenverr,'','no error output on test env from DuckPAN');

	run_ok( 'duckpan', [qw( rm test )], 'removing DuckPAN env test to me');

	is(io(file($tempdir,'env.ini'))->slurp,"",'checking content of env.ini');

	( undef, $getenvout, $getenverr ) = run_script( 'duckpan', [qw( env test )]);

	like($getenvout,qr/TEST is not set/,'getting test env from DuckPAN after removing it');
	is($getenverr,'','no error output on test env from DuckPAN after removing it');
}

done_testing;
