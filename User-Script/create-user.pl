#!/usr/bin/perl -w
# Created by Yohanes Patra.
# with the help from Jesus Christ.
# True Jesus Church my church.Lovely Church.Love ya all.
# www.tjc.org
#
# Create Secure UserName under *nix
#
# 0×71
use strict;
use Expect;

unless (@ARGV)
{
print "\nusage : $0 username ";
print "\nexample : $0 admin \n\n";
exit;
}

#Username Automatic creation
my $username = $ARGV[0];
open FH, " cat /etc/passwd | grep $username | ";
while () {
print "\n######### $username Already Created ########\n\n" if /$username/;
exit if /$username/;
}
close FH;

print "Creating Username : $username\n";
my $create = Expect->spawn("useradd -d /home/$username -m $username") or die "Cannot spawn passwd command";
$create -> soft_close;

# Passwd Section
my $password = join "",&generate_password(15);
my $exp = Expect->spawn("passwd $username") or die "Cannot spawn passwd command \n";
$exp -> expect (10, ["New UNIX password:"]);
$exp->send("$password\n");
$exp -> expect (10, ["Retype new UNIX password:"]);
$exp->send("$password\n");
$exp->soft_close();
print "\nusername : $username\npassword : $password\n";

sub generate_password {
my (@small_word,@big_word,@number,@sign,@result,$count_small,$count_big,$count_number,$count_sign,$counter);
@small_word = "a".."z";
@big_word = "A".."Z";
@number = "0″.."9″;
no warnings; {
@sign = qw { $ ! @ # };
}
#Auto assign counter.
# Modify how many no and sign that u need
$count_number = 2;
$count_sign = 2;
#

if ($_[0] % 2) {
$count_small = (($_[0] – (($count_number + $count_sign)+ 1) )/2);
$count_big = (($_[0] – (($count_number + $count_sign)- 1) )/2);
} else {
$count_small = ($_[0] – ($count_number + $count_sign)/2);
$count_big = ($_[0] – ($count_number + $count_sign)/2);
}

foreach (1..$_[0]) {
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
$count_number–;
} else {
$counter++;
}
}

if ($counter == 1) {
if ($count_sign != 0) {
push @result,$sign[rand @sign];
$count_sign–;
} else {
$counter++;
}

}

if ( $counter == 2) {
if ($count_small != 0) {
push @result,$small_word[rand @small_word];
$count_small–;
} else {
$counter++;
}
}

if ( $counter == 3) {
if ($count_big != 0) {
push @result,$big_word[rand @big_word];
$count_big–;
}
}

}
return @result;
}
