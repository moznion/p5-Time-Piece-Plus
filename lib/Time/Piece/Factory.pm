package Time::Piece::Factory;
use strict;
use warnings;
use 5.10.0;
our $VERSION = '0.01';

use Time::Piece;

sub import {
    my $class  = shift;
    my $caller = caller;

    unshift @_, 'Time::Piece';

    goto &Time::Piece::import;
}

package  Time::Piece;
use strict;
use warnings;

use Time::Seconds;
use Data::Validator;

sub get_object {
    my ($self, ) = @_;

    $self = $self->localtime unless ref $self;
    return $self;
}

sub reparse {
    my ($self, $format_string, $parse_string) = @_;

    $parse_string ||= $format_string;
    $self->strptime($self->strftime($format_string), $parse_string);
}

sub yesterday {
    my ($self, ) = @_;

    $self = $self->get_object;

    $self->localtime(($self - ONE_DAY)->reparse('%Y%m%d'));
}

sub tomorrow {
    my ($self, ) = @_;

    $self = $self->get_object;

    $self->localtime(($self + ONE_DAY)->reparse('%Y%m%d'));
}

my %TRUNCATE_FORMAT = (
    minute  => '%Y%m%d%H%I00',
    hour    => '%Y%m%d%H0000',
    day     => '%Y%m%d000000',
    month   => '%Y%m01000000',
    year    => '%Y0101000000',
);

use Mouse::Util::TypeConstraints;

enum 'Time::Piece::Factory::ColumTypes' => keys %TRUNCATE_FORMAT;

no Mouse::Util::TypeConstraints;

sub truncate {
    state $validator = Data::Validator->new(
        to => {isa => 'Time::Piece::Factory::ColumTypes'},
    )->with(qw(Method));
    my ($self, $args) = $validator->validate(@_);
    my $format = $TRUNCATE_FORMAT{$args->{to}};
    $self = $self->get_object;
    return $self->reparse($format);
}

1;
__END__

=head1 NAME

Time::Piece::Factory - Factory module for Time::Piece

=head1 SYNOPSIS

  use Time::Piece::Factory;

  my $time = Time::Piece->yesterday;
  my $two_days_ago = $time->yesterday;

=head1 DESCRIPTION

Time::Piece::Factory is

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
