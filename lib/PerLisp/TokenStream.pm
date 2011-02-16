package PerLisp::TokenStream;
use PerLisp::Base -base;

has tokens => sub { [] };

sub add {
    my $self = shift;
    push @{$self->tokens}, @_;
}

sub next_token {
    my $self = shift;
    return shift @{$self->tokens};
}

sub look_ahead {
    my $self = shift;
    return $self->tokens->[0];
}

sub is_empty {
    my $self = shift;
    return @{$self->tokens} == 0;
}

sub to_string {
    my $self    = shift;
    my @strings = map { $_->to_string } @{$self->tokens};
    return join '' => map { "$_\n" } @strings;
}

1;
__END__
