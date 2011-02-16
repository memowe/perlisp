package PerLisp::Base;
# simplified version of Mojo::Base - thanks, sri!

use strict;
use warnings;

# export stuff to subclasses
sub import {
    
    # perlisp classes are strict!
    strict->import;
    warnings->import;
}

# basic constructor
sub new {
    my $class = shift;
    my $self = exists $_[0] ? exists $_[1] ? {@_} : {%{$_[0]}} : {};
    return bless $self, ref $class || $class;
}

# accessor generator
sub attr {
    my ($class, $attr, $default) = @_;

    # check attr name
    die "Attribute '$attr' invalid.\n" unless $attr =~ /^[a-zA-Z_]\w*$/;

    # check default
    die "Default has to be a code reference or constant value.\n"
        if ref $default && ref $default ne 'CODE';

    # allow symbolic references
    no strict 'refs';

    # create attribute accessor
    *{"${class}::$attr"} = sub {
        my $self = shift;
        if (@_ == 0) { # getter
            if (defined $default) {
                return $self->{$attr} if exists $self->{$attr};
                return $self->{$attr} = ref $default eq 'CODE' ?
                    $default->($self) : $default;
            }
            else {
                return $self->{$attr};
            }
        }
        else { # setter
            my $new_value  = shift;
            $self->{$attr} = $new_value;
            return $self; # method chaining
        }
    };
}

1;
__END__
