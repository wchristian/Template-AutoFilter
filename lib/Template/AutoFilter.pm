use strict;
use warnings;

package Template::AutoFilter;

# VERSION
# ABSTRACT: Template::Toolkit with automatic filtering

=head1 SYNOPSIS

    use Template::AutoFilter;

    my $templ = "[% str %]  [% str | none %]  [% str | url %]";

    my $out;
    Template::AutoFilter->new->process( \$templ, { str => '<a>' }, \$out );

    print $out; # "&lt;a&gt;  <a>  %3Ca%3E"

    my $out;
    Template::AutoFilter->new( AUTO_FILTER => 'upper' )->process( \$templ, { str => '<a>' }, \$out );

    print $out; # "<A>  <a>  %3Ca%3E"

=head1 DESCRIPTION

Template::AutoFilter is a subclass of Template::Toolkit which loads a
specific Parser that is subclassed from Template::Parser. It adds a
filter instruction to each interpolation token found in templates
loaded by the TT engine. Tokens that already have a filter instruction
are left unchanged.

By default this automatic filter is set to be 'html', but can be modified
during object creation by passing the AUTO_FILTER option with the name
of the wanted filter.

Additionally a pass-through filter called 'none' is added to the object to
allow exclusion of tokens from being filtered.

Lastly, if you have problems with the directives which get auto filters
applied, you can see the L<Template::AutoFilter::Parser> docs for how you
can customize that.

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

All parameters passed to this new() will also be passed to the parser's
new().

=head1 CONTRIBUTORS

Ryan Olson (cpan:GIMPSON) <ryan@ziprecruiter.com>

=cut

use base 'Template';

use lib '..';
use Template::AutoFilter::Parser;

sub new {
    my $class = shift;

    my $params = defined($_[0]) && ref($_[0]) eq 'HASH' ? shift : {@_};

    $params->{PARSER} ||= Template::AutoFilter::Parser->new( $params );

    my $self = $class->SUPER::new( $params );

    if ( ! $self->context->filter('none') ) {
      $self->context->define_filter('none',sub { $_[0] });
    }

    return $self;
}

1;
