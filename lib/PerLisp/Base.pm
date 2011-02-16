package PerLisp::Base;
# simplified version of Mojo::Base - thanks, sri!

use strict;
use warnings;

# use "use" for inheritance
sub import {
    my ($class, $arg) = @_;
    
    # perlisp classes are strict!
    strict->import;
    warnings->import;

    # inheritance wanted?
    return unless $arg;

    # preparations
    no strict 'refs';
    no warnings 'redefine';
    my $caller = caller;

    # subclass from PerLisp::Base
    if ($arg eq '-base') {
        $arg = 'PerLisp::Base';
    }

    # subclass from an other class
    else {
        my $filename = $arg;
        $filename =~ s|::|/|g;

        # load unless loaded
        require "$filename.pm" unless $arg->can('new');
    }

    # inheritance
    push @{"${caller}::ISA"}, $arg;

    # export a moose like attribute helper
    *{"${caller}::has"} = sub { attr($caller, @_) };
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
