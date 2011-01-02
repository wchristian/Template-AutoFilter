#!/usr/bin/perl

use strict;
use warnings;

package autofilter;

use lib 'lib';
use lib '../lib';

use Template::AutoFilter;
use Template::AutoFilter::Parser;

my $templ = "unfiltered: [% test | none %] <a>
filtered (html): [% test %] [% test | html %]
filtered (upper): [% test | upper %]";

my $tt = Template::AutoFilter->new;
my $out;
$tt->process( \$templ, { test => '<a>' }, \$out ) or die $tt->error();
print $out;

exit;
