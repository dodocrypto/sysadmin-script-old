#!/usr/bin/perl -w
# [0day (xc) Our] 
# http://0dev.us.to
# Minimum 2 word of number and 2 sign
# to default password
# Password must begin with word

use strict;
use Getopt::Std;

sub usage {
print " Usage : $0 [-dwo] [No of Character]
-d Specific how many no that will be generate.
-w Specific how many word that will be generate.
-o Specific others character to be generate.
Example $0 -d 5 -w 5 -o 5 15
"
}

if ( !@ARGV) {
&usage() and exit;
}

getopt ('-dwo');
our($opt_d, $opt_w, $opt_o);

my @result = &generate_password($ARGV[0]);

print "Length   : $ARGV[0] \nPassword : ";
print @result;

sub generate_password {
my (@small_word,@big_word,@number,@sign,@result,$count_small,$count_big,$count_number,$count_sign,$counter);
@small_word = "a".."z";
@big_word = "A".."Z";
@number = "0".."9";
no warnings; {
@sign = qw { $ ! @ # };
}
#Auto assign counter.
# Modify how many no and sign that u need
$count_number = 2;
$count_sign = 2;
#

if ($ARGV[0] % 2) {
$count_small = (($ARGV[0] - (($count_number + $count_sign)+ 1) )/2);
$count_big = (($ARGV[0] - (($count_number + $count_sign)- 1) )/2);
} else {
$count_small = ($ARGV[0] - ($count_number + $count_sign)/2);
$count_big = ($ARGV[0] - ($count_number + $count_sign)/2);
}

foreach (1..$ARGV[0]) {
$counter = int(rand(4));

# Loop to make counter to $counter = 0 if something full
if ( ( $count_big == 0 ) && ( $counter == 3)) {
$counter -= 3;
}
if (( $count_small == 0) && ( $counter == 2)) {
$counter -= 2;
}

if (($count_sign == 0) && ( $counter == 1)) {
$counter -= 1;
}

#########################################################

if ($counter == 0) {
if ($count_number != 0) {
push @result,$number[rand @number];
$count_number--;
} else {
$counter++;
}
}

if ($counter == 1) {
if ($count_sign != 0) {
push @result,$sign[rand @sign];
$count_sign--;
} else {
$counter++;
}

}

if ( $counter == 2) {
if ($count_small != 0) {
push @result,$small_word[rand @small_word];
$count_small--;
} else {
$counter++;
}
}

if ( $counter == 3) {
if ($count_big != 0) {
push @result,$big_word[rand @big_word];
$count_big--;
}
}

}
return @result;
}