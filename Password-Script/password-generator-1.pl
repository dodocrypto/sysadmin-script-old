#!/usr/bin/perl -w
# [0day (xc) Our] 
# http://0dev.us.to
# Included Lower Case , Upper Case, Number and Symbol.


use strict;

#Set How Long is the password

my $length_password = 20;

# set 2 for occurence of others symbol such as !@$%
# 2 for no 1 -- 9 the rest divide evenly with lower case and upper case.
my ( $no , $others ) = (2 , 2);

# set others symbol to be included in password just expand the list of others

######### Do not Edit Below this Line #############

my ( $small , $big );
if (($length_password -4) % 2) {
$big = ( ( ($length_password -4 ) + 1 ) /2 );
$small = (($length_password -4 ) -$big);
} else {
$big = (($length_password -4 ) /2 );
$small =( ($length_password -4 ) -$big);
}

print "#### Length of password : $length_password\n";
print "#### The Password is : ";

foreach (1..$length_password) {
#big logic
my $counter = int (rand(4));

# Loop to make counter to $counter = 0 if something full
if ( $others eq 0 ) {
if ( $counter eq 3) {
$counter -= 3;
}
}
if ( $no eq 0) {
if ( $counter eq 2) {
$counter -= 2;
}
}
if ($small eq 0) {
if ( $counter eq 1) {
$counter -= 1;
}
}
#########################################################

########### Statement to Generate it properly ###################

if ($counter eq 0){
if ($big != 0) {
print &b_word;
--$big;
} else {
$counter +=1;
}
}

if ($counter eq 1) {
if ($small != 0) {
print &s_word;
--$small;
} else {
$counter +=1;
}
}

if ($counter eq 2) {
if ($no != 0) {
print &no;
--$no;
} else {
$counter +=1;
}
}
if ($counter eq 3) {
if ($others != 0) {
print &others;
--$others;
}
}
}

sub s_word {
my @s_word = 'a'..'z';
my $result_s = $s_word[rand @s_word];
return $result_s;
}
sub b_word {
my @b_word = 'A'..'Z';
my $result_b = $b_word[rand @b_word];
return $result_b;
}
sub no {
my @no = '0'..'9';
my $result_no = $no[rand @no];
return $result_no;
}
sub others {
no warnings;
my @others = qw ( ! @ $ % # -- _ + );
my $result_o = $others[rand @others];
return $result_o;
}
print "\n";