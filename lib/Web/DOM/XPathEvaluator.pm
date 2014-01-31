package Web::DOM::XPathEvaluator;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
push our @CARP_NOT, qw(Web::DOM::TypeError Web::DOM::Exception);

sub new ($) {
  return bless {}, $_[0];
} # new

sub create_expression ($$;$) {
  my $expr = ''.$_[1];
  my $resolver = sub { undef };
  if (not defined $_[2]) {
    #
  } elsif (ref $_[2] eq 'CODE') {
    my $code = $_[2];
    $resolver = sub {
      my $prefix = $_[0];
      my $url = eval { $code->($code, $prefix) };
      if ($@) { warn $@ } # XXX error reporting
      return defined $url ? ''.$url : undef;
    };
  } else {
    unless (UNIVERSAL::isa ($_[2], 'Web::DOM::XPathNSResolver')) {
      _throw Web::DOM::TypeError
          'The second argument is not an XPathNSResolver';
    }
    my $obj = $_[2];
    $resolver = sub {
      my $prefix = $_[0];
      return $obj->lookup_namespace_uri ($prefix); # or undef
    };
  }

  require Web::XPath::Parser;
  my $parser = Web::XPath::Parser->new;
  $parser->ns_resolver ($resolver);
  my $ns_error;
  my $onerror = $parser->onerror;
  $parser->onerror (sub {
    my %args = @_;
    $ns_error = $args{value} if $args{type} eq 'namespace prefix:not declared';
    $onerror->(%args);
  });
  my $parsed = $parser->parse_char_string_as_expression ($expr);
  if (defined $parsed) {
    require Web::DOM::XPathExpression;
    return bless \$parsed, 'Web::DOM::XPathExpression';
  } elsif (defined $ns_error) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The specified expression has unresolvable namespace prefix |' . $ns_error . '|';
  } else {
    _throw Web::DOM::Exception 'SyntaxError',
        'The specified expression is syntactically invalid';
  }
} # create_expression

sub create_ns_resolver ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  require Web::DOM::XPathNSResolver;
  return bless \($_[1]), 'Web::DOM::XPathNSResolver';
} # create_ns_resolver

sub evaluate ($$$;$$$) {
  # WebIDL
  my $expr = ''.$_[1];
  unless (UNIVERSAL::isa ($_[2], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The second argument is not a Node';
  }
  if (defined $_[3] and ref $_[3] ne 'CODE') {
    unless (UNIVERSAL::isa ($_[3], 'Web::DOM::XPathNSResolver')) {
      _throw Web::DOM::TypeError
          'The third argument is not an XPathNSResolver';
    }
  }
  my $type = unpack 'S', pack 'S', ($_[4] || 0) % 2**16; # WebIDL unsigned short
  if (defined $_[5] and (not ref $_[5] or not UNIVERSAL::can ($_[5], 'isa'))) { # WebIDL object?
    _throw Web::DOM::TypeError 'The fifth argument is not an object';
  }

  $expr = $_[0]->create_expression ($expr, $_[3]); # or exception
  return $expr->evaluate ($_[2], $type, $_[5]); # or exception
} # evaluate

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
