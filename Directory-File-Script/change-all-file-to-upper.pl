#!/usr/bin/perl -w
# [0day (xc) Our] 
# http://0dev.us.to
#Change all files to uppercase (Files only)


use strict;

# Create 2 Variable
my ($old_file_name,$temp);

# Take User Input ! is not @ARGV in perl take command line from user
# it will be read if user do not enter any command
if (!@ARGV) {
# display usage $0 name of the perl file, exit if the user didnt input anything.
print 'usage $0 directory \n'  and exit; }

## Calling perl sub function called Recursive with input from user $ARGV[0] is the first user input .
&recursive ($ARGV[0]);

#### Declare Function
sub recursive {
#### Open Directory from user input,called DIR, Get Function input which is $ARGV[0]
#### if the system are not able to open it print $_[0] which is directory that the user input
#### $!
opendir (DIR, $_[0]) or die 'Unable to open $_[0]: $!';

#### declare array ! not / ^ beginning of file , \. which is dot {1,2} one dot and two dot . ..
#### read directory handler
#### put the values in @files array

# sort @files to exclude . ..

my @files = grep {!/^\.{1,2}/} readdir (DIR);

#### Close file handler
closedir (DIR);

#### Sort @files array put @files string with / infront of them
@files = map { $_[0] . '/' . $_ } @files;

##### Called all loop in the string
foreach (@files) {
##### if string is directory
if (-d $_) {
## called recursive function
&recursive($_);
## if it is not directory , set old_filename to string
} else {
$old_file_name = $_;
print '$_\n';

## if string contain / set $temp to $1
if ( /.*\/(.*)$/ ) {
$temp = $1;
}
### replace the current string to all upper case.
s/$temp/\U$temp\E/;
}
# turn off warnings
no warnings; {
### rename the file to all upper case
rename ($old_file_name, $_);
}
}
}