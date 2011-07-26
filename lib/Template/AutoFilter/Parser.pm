use strict;
use warnings;

package Template::AutoFilter::Parser;

# VERSION
# ABSTRACT: parses TT templates and automatically adds filters to tokens

=head1 DESCRIPTION

Sub-class of Template::Parser.

=head1 METHODS

See L<Template::Parser> for most of these, documented here are added
methods.

=head2 new

Accepts all the standard L<Template::Parser> parameters, plus some extra:

=head3 AUTO_FILTER

Accepts a single string, which defines the name of a filter to be applied
to all directives omitted from the skip list. This parameter defaults to
'html'.

=head3 SKIP_DIRECTIVES

Allows customization of which L<Template::Manual::Directives> should be
exempt from having auto filters applied. Expects an array ref of strings.
Default value is the output from $self->default_skip_directives.

=head2 split_text

Modifies token processing by adding the filter specified in AUTO_FILTER
to all filter-less interpolation tokens.

=head2 has_skip_field

Checks the field list of a token to see if it contains directives that
should be excluded from filtering.

=head2 default_skip_directives

Provides a reference to a hash containing the default directives to be
excluded. Default value is:

    CALL SET DEFAULT INCLUDE PROCESS WRAPPER BLOCK IF UNLESS ELSIF ELSE
    END SWITCH CASE FOREACH FOR WHILE FILTER USE MACRO TRY CATCH FINAL
    THROW NEXT LAST RETURN STOP CLEAR META TAGS DEBUG


=head2 make_skip_directives

Prebuilds a hash of directives to be skipped while applying auto filters.

=cut

use base 'Template::Parser';

sub new {
    my ( $class, $params ) = @_;

    my $self = $class->SUPER::new( $params );
    $self->{AUTO_FILTER} = $params->{AUTO_FILTER} || 'html';
    $self->{SKIP_DIRECTIVES} = $self->make_skip_directives( $params->{SKIP_DIRECTIVES} ) || $self->default_skip_directives;

    return $self;
}

sub split_text {
    my ( $self, @args ) = @_;
    my $tokens = $self->SUPER::split_text( @args ) or return;

    for my $token ( @{$tokens} ) {
        next if !ref $token;

        my %fields = grep { !ref } @{$token->[2]}; # filter out nested fields, they don't matter for our decision of whether there is a filter already
        next if $self->has_skip_field( \%fields );

        push @{$token->[2]}, qw( FILTER | IDENT ), $self->{AUTO_FILTER};
    }

    return $tokens;
}

sub has_skip_field {
    my ( $self, $fields ) = @_;

    my $skip_directives = $self->{SKIP_DIRECTIVES};

    for my $field ( keys %{$fields} ) {
        return 1 if $skip_directives->{$field};
    }

    return 0;
}

sub default_skip_directives {
    my ( $self ) = @_;
    my @skip_directives = qw(
        CALL SET DEFAULT INCLUDE PROCESS WRAPPER BLOCK IF UNLESS ELSIF ELSE
        END SWITCH CASE FOREACH FOR WHILE FILTER USE MACRO TRY CATCH FINAL
        THROW NEXT LAST RETURN STOP CLEAR META TAGS DEBUG
    );
    return $self->make_skip_directives( \@skip_directives );
}

sub make_skip_directives {
    my ( $self, $skip_directives_list ) = @_;
    return if !$skip_directives_list;

    my %skip_directives = map { $_ => 1 } @{$skip_directives_list};
    return \%skip_directives;
}

1;
