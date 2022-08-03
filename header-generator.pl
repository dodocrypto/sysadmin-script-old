#!/usr/bin/perl 
# [0day (xc) Our] 
# http://0dev.us.to
# Contact irc.freenode.net channel ##0dev
 
#### Dont Edit this line
### usage -p mean for php -c c and c++ -e perl
 
 
 
if ((!@ARGV) || (!$ARGV[0] =~ /-p/) || ( !$ARGV[0] =~ /-c/ ) || (!$ARGV[0] =~ /-e/)) {
    print "0x71 $! Generate Header usage : -p for php, -c c and c++ and -e for perl\n" and exit;
}
 
 
# Declare all variable
$your_name;
$time;
$license;
$team;
$city_or_place_where_you_code_your_code;
$purpose_of_the_program;
 
# Never Edit this line which is time
$time = localtime;
 
# Set value. You can edit here or what i mean is edit this variable accordingly.
$your_name = "immanuel yohanes patra (skraito)";
$license = "License by $team hacker team. \nYou cant use. You cant see. You cant do anything and finally you can't modify";
$team = "0x71";
$city_or_place_where_you_code_your_code = "Pekanbaru";
$purpose_of_the_program = "$team Generate Header";
$website_of_your_team = "http:\\0x71.org";
### Edit this. for windows put ure drive which is d:\\with_ure_directory_here or file_name
$file_name_you_want_to_write_to = "~/0x71.pl";
 
##### Don't Edit this line
if ($ARGV[0] =~ /-e/) {
open FILE, ">", "$file_name_you_want_to_write_to";
print FILE "#!/usr/bin/perl -w
# $your_name with Lord ( Jesus Christ )
# Thank You Lord ( Jesus Christ ) for this knowledge
# Coded in $city_or_place_where_you_code_your_code at $time
# Love ya all True Jesus Church, my comrade as christian
# http:/www.tjc.org
# and lastly to our team $team, $website_of_your_team
# Purpose of the program :
# $purpose_of_the_program
# 
#
 
";
close FILE;
}
 
if ($ARGV[0] =~ /-p/) {
open FILE, ">", "$file_name_you_want_to_write_to";
print FILE "/* $your_name with Lord ( Jesus Christ )
* Thank You Lord ( Jesus Christ ) for this knowledge
* Coded in $city_or_place_where_you_code_your_code at $time
* Love ya all True Jesus Church, my comrade as christian
* http:/www.tjc.org
* and lastly to our team $team, $website_of_your_team
* Purpose of the program :
* $purpose_of_the_program
* 
*
*/
 
";
close FILE;
}
 
if ($ARGV[0] =~ /-c/) {
open FILE, ">", "$file_name_you_want_to_write_to";
print FILE "/* $your_name with Lord ( Jesus Christ )
* Thank You Lord ( Jesus Christ ) for this knowledge
* Coded in $city_or_place_where_you_code_your_code at $time
* Love ya all True Jesus Church, my comrade as christian
* http:/www.tjc.org
* and lastly to our team $team, $website_of_your_team
* Purpose of the program :
* $purpose_of_the_program
* 
*
*/
 
";
close FILE;
}