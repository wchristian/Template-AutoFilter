#!/usr/bin/perl

use strict;
use warnings;

package autofilter;

use Test::InDistDir;
use Test::More 0.96 ();
use Test::Most;

use Template::Filters;

run_tests();
done_testing;

exit;

sub tests {(
    {
        name => 'plain text remains unfiltered',
        tmpl => '<a>',
        expect => '<a>',
    },
    {
        name => 'excluded tokens remain unfiltered',
        tmpl => '[% test | none %]',
        expect => '<a>',
    },
    {
        name => 'unfiltered tokens get filtered',
        tmpl => '[% test %]',
        expect => '&lt;a&gt;',
    },
    {
        name => 'specifically filtered tokens get filtered',
        tmpl => '[% test | html %]',
        expect => '&lt;a&gt;',
    },
    {
        name => 'other filters are applied without the autofilter',
        tmpl => '[% test | upper %]',
        expect => '<A>',
    },
    {
        name => 'parameters make it possible to set the autofilter',
        tmpl => '[% test %]',
        expect => '<A>',
        params => { AUTO_FILTER => 'upper' }
    },
    {
        name => 'includes are not filtered',
        tmpl => '[% test %] [% INCLUDE included.tt %]',
        expect => "<A> test <html> <A>\n",
        params => {
            AUTO_FILTER => 'upper',
            INCLUDE_PATH => 't',
        },
    },
    {
        name => 'SKIP_DIRECTIVES modifications are observed',
        tmpl => '[% test %] [% INCLUDE included.tt %]',
        expect => "<A> TEST <HTML> <A>\n",
        params => {
            AUTO_FILTER => 'upper',
            INCLUDE_PATH => 't',
            SKIP_DIRECTIVES => [],
        },
    },
    {
        name => '[%# comments are parsed correctly',
        tmpl => 'pre[%# This is a comment -%]post',
        expect => 'prepost',
    },
    {
        name => '[% # comments are parsed correctly',
        tmpl => 'pre[% # This is a comment -%]post',
        expect => 'prepost',
    },
    {
        name => 'empty tokens are parsed correctly',
        tmpl => 'pre[% -%]post',
        expect => 'prepost',
    },
    {
        name => 'none included with sent filters',
        tmpl => '[% test | none %][% test | passed %]',
        expect => '<a>passed<a>passed',
        params => {
          LOAD_FILTERS => Template::Filters->new(
                              { FILTERS => { passed => sub { "passed$_[0]passed" } } }
                          ),
        },
    }
)}

sub run_tests {
    use_ok "Template::AutoFilter";

    run_test($_) for tests();

    return;
}

sub run_test {
    my ( $test ) = @_;
    $test->{params} ||= {};

    my $tt = Template::AutoFilter->new( $test->{params} );
    my $out;
    my $res = $tt->process( \$test->{tmpl}, { test => '<a>' }, \$out );

    subtest $test->{name} => sub {
        cmp_deeply( [ $tt->error."", $res ], [ '', 1 ], 'no template errors' );

        is( $out, $test->{expect}, 'output is correct' );
    };

    return;
}
