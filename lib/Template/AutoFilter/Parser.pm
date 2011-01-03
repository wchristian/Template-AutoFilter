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

=head2 has_skip_field

Checks the field list of a token to see if it contains directives that
should be excluded from filtering.

=head2 skip_fields

Provides a reference to a hash containing all directives to be excluded.

=cut

use base 'Template::Parser';

my %skip_fields = (
    CALL => 1, SET => 1, DEFAULT => 1, INCLUDE => 1, PROCESS => 1, WRAPPER => 1, BLOCK => 1, IF => 1, UNLESS => 1, ELSIF => 1, ELSE => 1,
    END => 1, SWITCH => 1, CASE => 1, FOREACH => 1, FOR => 1, WHILE => 1, FILTER => 1, USE => 1, MACRO => 1, TRY => 1, CATCH => 1, FINAL => 1,
    THROW => 1, NEXT => 1, LAST => 1, RETURN => 1, STOP => 1, CLEAR => 1, META => 1, TAGS => 1, DEBUG => 1,
);

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
        next if has_skip_field( \%fields );

        push @{$token->[2]}, qw( FILTER | IDENT ), $self->{AUTO_FILTER};
    }

    return $tokens;
}

sub skip_fields { \%skip_fields }

sub has_skip_field {
    my ( $fields ) = @_;

    my $skip_fields = skip_fields();

    for my $field ( keys %{$fields} ) {
        return 1 if $skip_fields->{$field};
    }

    return 0;
}

1;
