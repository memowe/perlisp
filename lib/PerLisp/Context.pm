package PerLisp::Context;
use base 'PerLisp::Base';

use strict;
use warnings;

__PACKAGE__->attr(binds => sub { {} });

sub get {
    my ($self, $name) = @_;

    die "Couldn't find $name in context.\n"
        unless exists $self->binds->{$name};

    return $self->binds->{$name};
}

sub set {
    my ($self, $name, $value) = @_;

    die "Symbol $name already bound.\n"
        if exists $self->binds->{$name};

    $self->binds->{$name} = $value;
}

# returns a new context with old and new bindings
sub specialize {
    my ($self, $new) = @_;

    # clone
    my %binds = %{$self->binds};

    # merge
    $binds{$_} = $new->{$_} for keys %$new;

    # create a new context
    return PerLisp::Context->new(
        binds => \%binds,
    );
}

1;
__END__
