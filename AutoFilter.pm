use strict;
use warnings;

package Template::AutoFilter;

=head1 SYNOPSIS

    use Template::AutoFilter 'html';

    my $tt = Template->new;

    # etc.

=head1 DESCRIPTION

Template::AutoFilter loads Template and then modifies Template::Parser to add the
filter defined in the first import parameter to every token encountered that does not
have a filter yet.

In order to allow exclusions it also adds a pass-through filter called 'none' to Template::Filters that just returns what it's given.

WARNING: This module is not very nice and highly experimental. I have not done a lot
of testing and things might blow up in unexpected ways. Use at your own risk.

=cut

use Template;
use Template::Parser;
use Template::Filters;

sub import {
    my ( $self, $filter ) = @_;

    $filter ||= 'html';

    replace_token_splitter( $filter );

    $Template::Filters::FILTERS->{none} = sub { $_[0] };

    return;
}

sub replace_token_splitter {
    my ( $filter ) = @_;
    no warnings 'redefine';

    my $old_split = \&Template::Parser::split_text;
    *Template::Parser::split_text = make_new_split( $old_split, $filter );

    return;
}

sub make_new_split {
    my ( $old_split, $filter ) = @_;

    my $new_split = sub {
        my $tokens = $old_split->(@_) or return;

        add_auto_filters( $_, $filter ) for @{$tokens};

        return $tokens;
    };

    return $new_split;
}

sub add_auto_filters {
    my ( $token, $filter ) = @_;

    my $field_list = $token->[2];
    return if grep { $field_list->[$_] eq 'FILTER' and !( $_ % 2 ) } 0..$#{$field_list};

    push @{$field_list}, qw( FILTER | IDENT ), $filter;
    return;
}

1;
