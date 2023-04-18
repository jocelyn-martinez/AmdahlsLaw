#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Graph Amdahl's law using SVG
# Jocelyn Martinez, All rights reserved, 2023.
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Carp;

my $XX    = 2000; my $YY = 1000;                                                # Size of display
my $N     = 1000;                                                               # Size of drawing area
my $Delta = 10;                                                                 # Length of line segments
my $Scale = 10;                                                                 # Scale factor

my @colors = qw(red green blue orange);                                         # Line colors

sub xc($)                                                                       # Transform x component
 {my ($x) = @_;
  $x + 100
 }

sub yc($)                                                                       # Transform y component for time
 {my ($y) = @_;
  $YY  - $y / 2
 }

sub YC($)                                                                       # Transform y component fpr speed up
 {my ($y) = @_;
  $YY - $y / $Scale
 }

my $nextColor = 0;                                                              # Choose next color

my @lines;

for my $n(2, 4, 6, 8)                                                           # Number of processors
 {my $color = $colors[$nextColor++];

  for my $p(map {$_ * $Delta} 0..int($N/$Delta)-1)                              # Parallel component
   {my $s = $N-$p;                                                              # Sequential component
    my $S = $s - $Delta; my $P = $p + $Delta;
    my $y =   ($s + $p / $n);
    my $Y =   ($S + $P / $n);
    my $t = yc($y);
    my $T = yc($Y);
    my $f = YC($YY*$N / $y);
    my $F = YC($YY*$N / $Y);                                                    # Lines
    my $x = xc $p; my $X = $P;                                                  # add xc to $P if 3d output not required
    push @lines, <<END;
  <line x1="$x" y1="$f" x2="$X" y2="$F" stroke-width="4" stroke="$color"/>
  <line x1="$x" y1="$t" x2="$X" y2="$T" stroke-width="4" stroke="$color" stroke-dasharray="4"/>
END
   }
  my $ty = YC($N*$n);                                                           # Text
  $color = "black";
  push @lines, <<END;
<text x="$YY" y="$ty" fill="$color" font-size="2em">$n</text>
END
 }

my $lines = join "\n", @lines;                                                  # Lines svg

my $tax = 100;    my $tay = 100;                                                # Coordinates of title
my $tsx = 100;    my $tsy = 200;                                                # Coordinates of speed up title
my $ttx = $N+100; my $tty = $YY - $tsy/2;                                       # Coordinates of time title

my $svg = <<END;                                                                # Generated SVG
<svg version="1.1" width="$XX" height="$YY" xmlns="http://www.w3.org/2000/svg">
   $lines

  <text x="$tax" y="$tay" fill="black" font-size="2em">Amdahl's Law</text>
  <text x="$tsx" y="$tsy" fill="black">
      <tspan  font-size="2em" x="$tsx" dy="0">Speed up by number of processors</tspan>
      <tspan                  x="$tsx" dy="50">Parallelism increases left to right</tspan>
      <tspan                  x="$tsx" dy="25">Speed up increases with parallelism and parallels</tspan>
      <tspan                  x="$tsx" dy="25">Time decreases with parallelism and processors</tspan>
      <tspan                  x="$tsx" dy="25">Copyright Jocelyn Martinez, 2023</tspan>
  </text>
  <text x="$ttx" y="$tty" fill="black" font-size="2em">Time</text>
</svg>
END

if (1)                                                                          # Write results to a file
 {open my $F, ">output.svg";
  binmode($F, ":utf8");
  print  {$F} $svg;
 }
