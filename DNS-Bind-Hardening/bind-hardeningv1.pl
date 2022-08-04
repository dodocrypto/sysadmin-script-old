#!/usr/bin/perl -w
# [0day (xc) Our] 
# http://0dev.us.to
# Setup Secure Bind (DNS) Tested under Centos 5
# dont forget to edit /etc/named.conf
# 

use strict;

# Install Bind using yum
system "yum install bind-chroot bind-libs bind-utils";

# 2 Create link /etc/named.conf and RNDC
unlink "/etc/named.conf" , "/etc/rndc.key" , "/var/named/chroot/var/named/etc/rndc.key", "/var/named/chroot/etc/named.conf";
system "touch /var/named/chroot/etc/named.conf /var/named/chroot/etc/rndc.key";
symlink "/var/named/chroot/etc/named.conf", "/etc/named.conf";
symlink "/var/named/chroot/etc/rndc.key", "/etc/rndc.key";

# 3 Generate rndc.key and TSIG

print "\n######## Generate rndc #######\n";
system "/usr/sbin/rndc-confgen -a";
my $key;
chomp (my $date = `date +%d%m%y`);
print "\n######## Generate DNSSEC #######\n";
chomp (my $keyfile = `/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n HOST $date`);
open DNSKEY, "$keyfile.key" or die "$!";
while () {
$key = $1 if /(?:.+) (?:.+) (?:.+) (?:.+) (?:.+) (?:.+) (.+)$/;
}
close DNSKEY;
unlink "$keyfile.key", "$keyfile.private";

# Generate The TSIG Key File

open DNSKEY, ">", "/var/named/chroot/etc/$date.TSIG.key" or die "$!";
print DNSKEY "key $date.TSIG {\nalgorithm hmac-md5;\nsecret \"$key\";\n};";
symlink "/var/named/chroot/etc/$date.TSIG.key", "/etc/$date.TSIG.key";
close DNSKEY;

# 4 Create named.conf
open NAMEDCONF, ">", "/var/named/chroot/etc/named.conf" or die "$!";
print NAMEDCONF "include \"/etc/rndc.key\";\n";
print NAMEDCONF "include \"/etc/$date.TSIG.key\";\n";
print NAMEDCONF "controls {\n\tinet 127.0.0.1 port 953\n\t allow { 127.0.0.1; }\n\t keys { \"rndckey\"; };\n\t};";

# 5 # SETUP ALLOWED ZONE TRANSFER IP

print "Do we Have Slave server ? [Y/N]: ";
chomp (my $slave_answer = <STDIN>);
if ( $slave_answer =~ /[yY].*/){
print "\nPlease Enter Slave server ip address : ";
chomp ( my @slave_ip = <STDIN>);
@slave_ip = map "$_" . ";" , @slave_ip;
print NAMEDCONF "\nacl \"xfer\" {\n \t//Allow no Transfers. If we have other\n \t//Name servers, place them here.\n";
for (@slave_ip) {
print NAMEDCONF "$_\n";
}
print NAMEDCONF "};\n";
} else {
print NAMEDCONF "acl \"xfer\" { \n\t none; //Allow no transfers. If we have other\n \t //Name servers, place them here.\n};\n";
}

# 6 # SETUP CLIENT THAT NEED TO BE ALLOWED RECURSIVE QUERY

print "\nDo we have Client to allowed Recursive Query? [Y/N]: ";
chomp (my $recursive_answer = <STDIN>);
if ( $recursive_answer =~ /[yY].*/){
print "\nPlease Enter Recursive Client ip address: ";
chomp ( my @recursive_ip = <STDIN> );
@recursive_ip = map "$_" . ";" , @recursive_ip;
print NAMEDCONF "\nacl \"trusted\" {
// Place our internal and DMZ subnets in here so that
// intranet and DMZ clients may send DNS queries. This
// also prevents outside hosts from using our name server
// as a resolver for other domains.";
for (@recursive_ip) {
print NAMEDCONF "$_\n";
}
print NAMEDCONF "localhost;\n};\n";
} else {
print NAMEDCONF "\nacl \"trusted\" {
// Place our internal and DMZ subnets in here so that
// intranet and DMZ clients may send DNS queries. This
// also prevents outside hosts from using our name server
// as a resolver for other domains.
localhost;
};\n";
}

### 7 Setup Bogon list

# SETUP BOGON LIST

print NAMEDCONF "
acl \"bogon\" {
// Filter out the bogon networks. These are networks
// listed by IANA as test, RFC1918, Multicast, experi-
// mental, etc. If you see DNS queries or updates with
// a source address within these networks, this is likely
// of malicious origin. CAUTION: If you are using RFC1918
// netblocks on your network, remove those netblocks from
// this list of blackhole ACLs!
0.0.0.0/8;
1.0.0.0/8;
2.0.0.0/8;
5.0.0.0/8;
10.0.0.0/8;
14.0.0.0/8;
23.0.0.0/8;
27.0.0.0/8;
31.0.0.0/8;
36.0.0.0/8;
37.0.0.0/8;
39.0.0.0/8;
42.0.0.0/8;
46.0.0.0/8;
49.0.0.0/8;
50.0.0.0/8;
100.0.0.0/8;
101.0.0.0/8;
102.0.0.0/8;
103.0.0.0/8;
104.0.0.0/8;
105.0.0.0/8;
106.0.0.0/8;
107.0.0.0/8;
108.0.0.0/8;
109.0.0.0/8;
110.0.0.0/8;
111.0.0.0/8;
169.254.0.0/16;
172.16.0.0/12;
175.0.0.0/8;
176.0.0.0/8;
177.0.0.0/8;
178.0.0.0/8;
179.0.0.0/8;
180.0.0.0/8;
181.0.0.0/8;
182.0.0.0/8;
183.0.0.0/8;
184.0.0.0/8;
185.0.0.0/8;
192.0.2.0/24;
192.168.0.0/16;
197.0.0.0/8;
198.18.0.0/15;
223.0.0.0/8;
224.0.0.0/3;
};\n";

# 8 SETUP LOGGING

# NAMED LOG WILL BE IN /var/named/chroot/var/named/log
#

system "mkdir -p /var/named/chroot/var/named/log";
print NAMEDCONF "
logging {
channel default_syslog {
// Send most of the named messages to syslog.
syslog local2;
severity debug;
};

channel audit_log {
// Send the security related messages to a separate file.
file \"/var/named/log/named.log\";
severity debug;
print-time yes;
};

category default { default_syslog; };
category general { default_syslog; };
category security { audit_log; default_syslog; };
category config { default_syslog; };
category resolver { audit_log; };
category xfer-in { audit_log; };
category xfer-out { audit_log; };
category notify { audit_log; };
category client { audit_log; };
category network { audit_log; };
category update { audit_log; };
category queries { audit_log; };
category lame-servers { audit_log; };

};\n";

# 9 SET OPTION FOR SECURITY
system "mkdir -p /var/named/chroot/var/named/pid /var/named/chroot/var/named/stats /var/named/chroot/var/named/dump";

print NAMEDCONF "
// Set options for security
options {
directory \"/var/named\";
pid-file \"/var/named/pid/named.pid\";
statistics-file \"/var/named/stats/named.stats\";
memstatistics-file \"/var/named/stats/named.memstats\";
dump-file \"/var/named/dump/named.dump\";
zone-statistics yes;

// Prevent DoS attacks by generating bogus zone transfer
// requests. This will result in slower updates to the
// slave servers (e.g. they will await the poll interval
// before checking for updates).
notify no;

// Generate more efficient zone transfers. This will place
// multiple DNS records in a DNS message, instead of one per
// DNS message.
transfer-format many-answers;

// Set the maximum zone transfer time to something more
// reasonable. In this case, we state that any zone transfer
// that takes longer than 60 minutes is unlikely to ever
// complete. WARNING: If you have very large zone files,
// adjust this to fit your requirements.
max-transfer-time-in 60;

// We have no dynamic interfaces, so BIND shouldnt need to
// poll for interface state {UP|DOWN}.
interface-interval 0;

allow-transfer {
// Zone tranfers limited to members of the
// \"xfer\" ACL.
xfer;
};

allow-query {
// Accept queries from our \"trusted\" ACL. We will
// allow anyone to query our master zones below.
// This prevents us from becoming a free DNS server
// to the masses.
trusted;
};

//allow-query-cache {
// Accept queries of our cache from our \"trusted\" ACL.
// trusted;
//};

blackhole {
// Deny anything from the bogon networks as
// detailed in the \"bogon\" ACL.
bogon;
};
};\n";

# 10 Setup Split Leg
# Internal

print NAMEDCONF "
view \"internal-in\" in {
// Our internal (trusted) view. We permit the internal networks
// to freely access this view. We perform recursion for our
// internal hosts, and retrieve data from the cache for them.

match-clients { trusted; };
recursion yes;
additional-from-auth yes;
additional-from-cache yes;

zone \".\" in {
// Link in the root server hint file.
type hint;
file \"db.cache\";
};

zone \"0.0.127.in-addr.arpa\" in {
// Allow queries for the 127/8 network, but not zone transfers.
// Every name server, both slave and master, will be a master
// for this zone.
type master;
file \"master/db.127.0.0\";

allow-query {
any;
};

allow-transfer {
none;
};
};";

# 11 Internal Zone view by Internal People

print "\nDo we want to serve internal Zone that can be only view by internal people ? [Y/N] : ";
chomp (my $v_internal_answer = <STDIN>);
if ( $v_internal_answer =~ /[yY].*/){
print "\n:Enter Fully Qualified Domain that we want ex: crap.crap.net\n";
print "Enter FQDN that you want : ";
chomp (my $v_internal_domain = <STDIN>);
print NAMEDCONF "
zone \"$v_internal_domain\" in {
// Our internal A RR zone. There may be several of these.
type master;
file \"master/db.$v_internal_domain\";
};\n";
}

# 12 PTR Internal RECORD SAMPLE

print "Do you want internal PTR RECORD? [Y/N]: ";
chomp (my $s_ptr_record_ans = <STDIN> );
if ( $s_ptr_record_ans =~ /[yY].*/){
print NAMEDCONF "
//Example of PTR RECORD INTERNAL PLease Edit Accordingly
zone \"7.7.7.in-addr.arpa\" in {
// Our internal PTR RR zone. Again, there may be several of these.
type master;
file \"master/db.7.7.7\";
};";
}

print NAMEDCONF "\n};\n";

# 13 Create External In

# CREATE VIEW IN
print NAMEDCONF "
// Create a view for external DNS clients.
view \"external-in\" in {
// Our external (untrusted) view. We permit any client to access
// portions of this view. We do not perform recursion or cache
// access for hosts using this view.

match-clients { any; };
recursion no;
additional-from-auth no;
additional-from-cache no;

// Link in our zones
zone \".\" in {
type hint;
file \"db.cache\";
};\n";

### Create FQDN for External Zone #####

print "\nEnter Fully Qualified Domain for External Zone : ";
chomp (my $externalfqdn = <STDIN>);
print NAMEDCONF "
zone \"$externalfqdn\" in {
type master;
file \"master/db.$externalfqdn\";

allow-query {
any;
};
};";

## SET EXTERNAL PTR ZONE #####
print "Do you want PTR RECORD for external zone ? [Y/N] : ";
chomp ( my $externalptr = <STDIN>);
if ( $externalptr =~ /[Yy].*/ ) {
print NAMEDCONF "
\\Sample Of PTR RECORD FOR EXTERNAL EDIT ACCORDINGLY
zone \"8.8.8.in-addr.arpa\" in {
type master;
file \"master/db.8.8.8\";

allow-query {
any;
};
}; ";
}
print NAMEDCONF "};\n";
### Create CHAOS zone

print NAMEDCONF "
// Create a view for all clients perusing the CHAOS class.
// We allow internal hosts to query our version number.
// This is a good idea from a support point of view.

view \"external-chaos\" chaos {
match-clients { any; };
recursion no;

zone \".\" {
type hint;
file \"/dev/null\";
};

zone \"bind\" {
type master;
file \"master/db.bind\";

allow-query {
trusted;
};
allow-transfer {
none;
};
};
};
";

# SET UP External FQDN ZONE
system "mkdir -p /var/named/chroot/var/named/master";
open EDOMAIN, ">", "/var/named/chroot/var/named/master/db.$externalfqdn" or die "$!";

print EDOMAIN "
\$TTL 86400
\@ IN SOA localhost. root.$externalfqdn. (
1997022700 ; Serial
28800 ; Refresh
14400 ; Retry
3600000 ; Expire
86400 ) ; Minimum
IN NS ns1.$externalfqdn.
IN A 69.162.120.26
www IN A 69.162.120.26
mail IN A 69.162.120.26
ns1 IN A 69.162.120.26
ns2 IN A 69.162.120.26
\n";

#### Setup DB 127.0.0

open EDOMAIN, ">", "/var/named/chroot/var/named/master/db.127.0.0″ or die "$!";
print EDOMAIN "
\$TTL 86400
\@ IN SOA localhost. root.localhost. (
1997022700 ; Serial
28800 ; Refresh
14400 ; Retry
3600000 ; Expire
86400 ) ; Minimum
IN NS localhost.
1 IN PTR localhost. \n";

# SET UP DB.CACHE
system "dig \@e.root-servers.net . ns > /var/named/chroot/var/named/db.cache";

# SET UP CHAOS db.bind
open DBBIND, ">" , "/var/named/chroot/var/named/master/db.bind" or die "$!";

print DBBIND "
\$TTL 1D
\$ORIGIN bind.
\@ 1D CHAOS SOA localhost. root.localhost. (
2001013101 ; serial
3H ; refresh
1H ; retry
1W ; expiry
1D ) ; minimum
CHAOS NS localhost.

version.bind. CHAOS TXT \"UNKNOWN\"
authors.bind. CHAOS TXT \"UNKNOWN\"
";

#### LASTLY SETTING UP PERMISSION ########

open BINDP, ">", "/root/bperm.bash";
print BINDP "
#!/bin/bash
# FIX PERMISSION ON CHROOT BIND
# COMPILE BY YOHANES

echo \"CHECK PERMISSION FOR BIND CHROOT
IF IT DID NOT SAY WRITEABLE ITS FINE
\"

ROOTDIR=/var/named/chroot
cd \$ROOTDIR
su -m named -c 'D=\$PWD; while [ \"\$D\" != \"/\" ]; do echo \$D;
test -w \$D && echo \$D is writable.; D=`dirname \$D`; done'

chown root:named \$ROOTDIR
chmod u=rwx,g=rx,o= \$ROOTDIR

# SET PERMISSION

cd \$ROOTDIR
chown -R root:named etc var
chmod -R g-w,o= etc var
chown root:named dev proc
chmod g-w,o=rx dev
chmod a=rx proc

chmod -R g+w var/run/named var/tmp var/named/log var/named/master var/named/data
chmod -R g+w var/named/slaves var/named/pid
";

## CLose ALL FILE HANDLER
close BINDP;
close DBBIND;
close EDOMAIN;
close NAMEDCONF;

system "chmod +x /root/bperm.bash";
system "/root/bperm.bash";
unlink "/root/bperm.bash";