package PerLisp::Context;
use base 'PerLisp::Base';

use strict;
use warnings;

__PACKAGE__->attr(stack => sub { [{}] });

# return top hashref of the stack
sub _binds {
    my $self = shift;
    return $self->stack->[-1];
}
sub to_hash { shift->_binds }

sub get {
    my ($self, $name) = @_;

    die "Couldn't find $name in context.\n"
        unless exists $self->_binds->{$name};

    return $self->_binds->{$name};
}

sub set {
    my ($self, $name, $value) = @_;

    die "Symbol $name already bound.\n"
        if exists $self->_binds->{$name};

    $self->_binds->{$name} = $value;
}

sub push {
    my ($self, $new) = @_;

    # copy
    my %binds = %{$self->_binds};

    # push
    push @{$self->stack}, \%binds;

    # merge
    while ( my ($name, $expr) = each %$new ) {
        $self->set($name => $expr);
    }
}

sub pop {
    my $self = shift;

    die "Couldn't pop: context stack height is 1.\n"
        if @{$self->stack} == 1;

    return pop @{$self->stack};
}

sub to_string {
    my $self = shift;

    return join '' => map {
        "$_ => " . $self->_binds->{$_}->to_string
    } sort keys %{$self->_binds};
}

1;
__END__
