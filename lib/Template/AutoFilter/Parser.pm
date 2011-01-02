use strict;
use warnings;

package Template::AutoFilter::Parser;

use parent 'Template::Parser';

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
        my $field_list = $token->[2];
        next if grep { $field_list->[$_] eq 'FILTER' and !( $_ % 2 ) } 0..$#{$field_list};

        push @{$field_list}, qw( FILTER | IDENT ), $self->{AUTO_FILTER};
    }

    return $tokens;
}

1;
