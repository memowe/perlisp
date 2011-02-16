#!/usr/bin/env perl

package Dog;
use PerLisp::Base -base;
has 'tail';
has color       => 'black';
has eye_color   => sub { 'brown' };
sub answer { 42 }

package SheepDog;
use PerLisp::Base 'Dog';
has 'name' => 'Sian';

package main;

use strict;
use warnings;

use Test::More tests => 37;

# constructors exist
ok(Dog->can('new'),         'Dog can new');
ok(SheepDog->can('new'),    'SheepDog can new');

# no constructor arguments
my $dog1 = Dog->new;
isa_ok($dog1, 'Dog', 'constructed Dog object');
ok($dog1->can('tail'),      'has tail accessor');
ok($dog1->can('color'),     'has color accessor');
ok($dog1->can('eye_color'), 'has left_eye accessor');
ok($dog1->can('answer'),    'has an answer method');
is($dog1->tail,         undef,      'tail undefined');
is($dog1->color,        'black',    'right default color');
is($dog1->eye_color,    'brown',    'right default eye_color');
is($dog1->answer,       42,         'right answer');

# with hashy constructor arguments
my $dog2 = Dog->new(tail => '30cm', color => 'red', eye_color => 'green');
is($dog2->tail,         '30cm',     'right tail value');
is($dog2->color,        'red',      'right color value');
is($dog2->eye_color,    'green',    'right eye_color value');
is($dog2->answer,       42,         'right answer');

# with a hashref constructor argument
my $dog3 = Dog->new({tail => '42cm', color => 'yellow', eye_color => 'black'});
is($dog3->tail,         '42cm',     'right tail value');
is($dog3->color,        'yellow',   'right color value');
is($dog3->eye_color,    'black',    'right eye_color value');
is($dog3->answer,       42,         'right answer');

# (chained) mutator tests
my $dog4 = Dog->new;
is($dog4->tail,                 undef,  'right tail value');
is($dog4->tail(42)->tail,       42,     'changed tail value');
is($dog4->tail(undef)->tail,    undef,  'changed tail value to undef');

# inheritance tests (no arguments)
ok(!Dog->new->can('name'), 'normal Dogs are anonymous');
my $sheepdog = SheepDog->new;
isa_ok($sheepdog, 'SheepDog',   'constructed SheepDog object');
isa_ok($sheepdog, 'Dog',        'constructed SheepDog object');
ok($sheepdog->can('tail'),      'has tail accessor');
ok($sheepdog->can('color'),     'has color accessor');
ok($sheepdog->can('eye_color'), 'has left_eye accessor');
ok($sheepdog->can('name'),      'has name accessor');
is($sheepdog->name, 'Sian',     'right default value');
is($sheepdog->answer, 42,       'right inherited answer method');

# inheritance tests with arguments
my $bob = SheepDog->new(name => 'Bob', color => 'blue');
is($bob->tail,      undef,      'right tail default value');
is($bob->color,     'blue',     'right color value');
is($bob->eye_color, 'brown',    'right default eye_color value');
is($bob->name,      'Bob',      'right name value');
is($bob->tail(17)->tail, 17,    'right changed tail value');
is($bob->answer,    42,         'right inherited answer method');

__END__
