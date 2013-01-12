package Web::DOM::Exception;
use strict;
use warnings;
no warnings 'utf8';
use Web::DOM::Error;
push our @ISA, qw(Web::DOM::Error);
our $VERSION = '1.0';
use Web::DOM::Internal;

our @EXPORT;
*import = \&Web::DOM::Internal::import;

sub INDEX_SIZE_ERR () { 1 }
sub DOMSTRING_SIZE_ERR () { 2 }
sub HIERARCHY_REQUEST_ERR () { 3 }
sub WRONG_DOCUMENT_ERR () { 4 }
sub INVALID_CHARACTER_ERR () { 5 }
sub NO_DATA_ALLOWED_ERR () { 6 }
sub NO_MODIFICATION_ALLOWED_ERR () { 7 }
sub NOT_FOUND_ERR () { 8 }
sub NOT_SUPPORTED_ERR () { 9 }
sub INUSE_ATTRIBUTE_ERR () { 10 }
sub INVALID_STATE_ERR () { 11 }
sub SYNTAX_ERR () { 12 }
sub INVALID_MODIFICATION_ERR () { 13 }
sub NAMESPACE_ERR () { 14 }
sub INVALID_ACCESS_ERR () { 15 }
sub VALIDATION_ERR () { 16 }
sub TYPE_MISMATCH_ERR () { 17 }
sub SECURITY_ERR () { 18 }
sub NETWORK_ERR () { 19 }
sub ABORT_ERR () { 20 }
sub URL_MISMATCH_ERR () { 21 }
sub QUOTA_EXCEEDED_ERR () { 22 }
sub TIMEOUT_ERR () { 23 }
sub INVALID_NODE_TYPE_ERR () { 24 }
sub DATA_CLONE_ERR () { 25 }

push @EXPORT, qw(
  INDEX_SIZE_ERR DOMSTRING_SIZE_ERR HIERARCHY_REQUEST_ERR
  WRONG_DOCUMENT_ERR INVALID_CHARACTER_ERR NO_DATA_ALLOWED_ERR
  NO_MODIFICATION_ALLOWED_ERR NOT_FOUND_ERR NOT_SUPPORTED_ERR
  INUSE_ATTRIBUTE_ERR INVALID_STATE_ERR SYNTAX_ERR
  INVALID_MODIFICATION_ERR NAMESPACE_ERR INVALID_ACCESS_ERR
  VALIDATION_ERR TYPE_MISMATCH_ERR SECURITY_ERR NETWORK_ERR ABORT_ERR
  URL_MISMATCH_ERR QUOTA_EXCEEDED_ERR TIMEOUT_ERR
  INVALID_NODE_TYPE_ERR DATA_CLONE_ERR
);

## <http://dom.spec.whatwg.org/#error-names-table>
my $NameToCode = {
  "IndexSizeError" => INDEX_SIZE_ERR,
  "HierarchyRequestError" => HIERARCHY_REQUEST_ERR,
  "WrongDocumentError" => WRONG_DOCUMENT_ERR,
  "InvalidCharacterError" => INVALID_CHARACTER_ERR,
  "NoModificationAllowedError" => NO_MODIFICATION_ALLOWED_ERR,
  "NotFoundError" => NOT_FOUND_ERR,
  "NotSupportedError" => NOT_SUPPORTED_ERR,
  "InvalidStateError" => INVALID_STATE_ERR,
  "SyntaxError" => SYNTAX_ERR,
  "InvalidModificationError" => INVALID_MODIFICATION_ERR,
  "NamespaceError" => NAMESPACE_ERR,
  "InvalidAccessError" => INVALID_ACCESS_ERR,
  "SecurityError" => SECURITY_ERR,
  "NetworkError" => NETWORK_ERR,
  "AbortError" => ABORT_ERR,
  "URLMismatchError" => URL_MISMATCH_ERR,
  "QuotaExceededError" => QUOTA_EXCEEDED_ERR,
  "TimeoutError" => TIMEOUT_ERR,
  "InvalidNodeTypeError" => INVALID_NODE_TYPE_ERR,
  "DataCloneError" => DATA_CLONE_ERR,
}; # $NameToCode

sub _throw ($$$) {
  my $class = shift;
  my $self = bless {name => $_[0], message => $_[1]}, $class;
  eval { Carp::croak };
  if ($@ =~ /at (.+) line ([0-9]+)\.?$/) {
    $self->{file_name} = $1;
    $self->{line_number} = $2;
  }
  # XXX stack
  die $self;
} # _throw

sub name ($) {
  return $_[0]->{name};
} # name

sub code ($) {
  return $NameToCode->{$_[0]->name} || 0;
} # code

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
