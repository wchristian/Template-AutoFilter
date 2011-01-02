use strict;
use warnings;

package Template::AutoFilter::Parser;

# ABSTRACT: parses TT templates and automatically adds filters to tokens

=head1 DESCRIPTION

Sub-class of Template::Parser.

=head1 METHODS

=head2 new

Accepts an extra parameter called AUTO_FILTER, which provides
the name of a filter to be applied. This parameter defaults to 'html'.

=head2 split_text

Modifies token processing by adding the filter specified in AUTO_FILTER
to all filter-less interpolation tokens.

=cut

use base 'Template::Parser';

sub new {
    my ( $class, $params ) = @_;

    my $self = $class->SUPER::new( $params );
    $self->{AUTO_FILTER} = $params->{AUTO_FILTER} || 'html';

    return $self;
}

sub split_text {
    my ( $self, @args ) = @_;
    my $tokens = $self->SUPER::split_text( @args ) or return;

    for my $token ( @{$tokens} ) {
        next if !ref $token;

        my %fields = @{$token->[2]};
        next if $fields{FILTER};

        push @{$token->[2]}, qw( FILTER | IDENT ), $self->{AUTO_FILTER};
    }

    return $tokens;
}

1;
