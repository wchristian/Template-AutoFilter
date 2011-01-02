use strict;
use warnings;

package Template::AutoFilter;

# ABSTRACT: Template::Toolkit with automatic filtering

=head1 SYNOPSIS

    use Template::AutoFilter;

    my $templ = "[% str | none %]  [% str %]";

    my $out;
    Template::AutoFilter->new->process( \$templ, { str => '<a>' }, \$out );

    print $out; # <a>  &lt;a&gt;

    my $out;
    Template::AutoFilter->new( AUTO_FILTER => 'upper' )->process( \$templ, { str => '<a>' }, \$out );

    print $out; # <a>  <A>

=head1 DESCRIPTION

Template::AutoFilter is a subclass of Template::Toolkit which loads a
specific Parser that is subclassed from Template::Parser and adds a
filter instruction to each interpolation token found in templates
loaded by the TT engine.

By default this automatic filter is set to be 'html', but can be modified
during object creation by passing the AUTO_FILTER option with the name
of the wanted filter.

Additionally a pass-through filter called 'none' is added to the object to
allow exclusion of tokens from being filtered.

WARNING: This module is highly experimental. I have not done a lot of
testing and things might blow up in unexpected ways. The API and behavior
might change with any release (until 1.0). If you'd like to see any changes
implemented, let me know via RT, email, IRC or by opening a pull request on
github.

Use at your own risk.

=head1 METHODS

=head2 new

Pre-processes the parameters passed on to Template's new(). Adds the
pass-through filter and creates the AutoFilter Parser.

=cut

use base 'Template';

use lib '..';
use Template::AutoFilter::Parser;

sub new {
    my $class = shift;

    my $params = defined($_[0]) && ref($_[0]) eq 'HASH' ? shift : {@_};
    $params->{FILTERS}{none} ||= sub { $_[0] };

    $params->{PARSER} ||= Template::AutoFilter::Parser->new( $params );

    return $class->SUPER::new( $params );
}

1;
