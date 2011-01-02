use strict;
use warnings;

package Template::AutoFilter;

use base 'Template';


sub new {
    my $class = shift;

    my $params = defined($_[0]) && ref($_[0]) eq 'HASH' ? shift : {@_};
    $params->{FILTERS}{none} ||= sub { $_[0] };

    $params->{PARSER} ||= Template::AutoFilter::Parser->new( $params );

    return $class->SUPER::new( $params );
}

1;
