#!/usr/bin/perl -w
# [0day (xc) Our] 
# http://0dev.us.to
# Contact irc.freenode.net channel ##0dev

use strict;
use File::Copy;

my ($whoami);

chomp ($whoami = `whoami`);
die "You need to be root to run this program" unless $whoami eq "root";

# Perform System Update.
print "################ Securing REDHAT 5 ################\n";
print "#### Make Sure you can get the update using yum ##\n\n";

print "\n#### Step 1 Updating the System #####\n" unless -e "/root/secure_log/runned";
&system_update() unless -e "/root/secure_log/runned";

print "\n#### Step 2 Hardening SSH ######\n" unless -e "/root/secure_log/runned.ssh";
&system_ssh_hardening() unless -e "/root/secure_log/runned.ssh";

print "\n#### Step 3 Disable Services #####\n";
&system_services();

print "\n#### Step 4 Hardeing User Account #####\n" unless -e "/root/secure_log/runned.user.account";
&system_user_account() unless -e "/root/secure_log/runned.user.account";

print "\n#### Step 5 Futher Hardening " unless -e "/root/secure_log/runned.further";
further_hardening() unless -e "/root/secure_log/runned.further";

print "\n#### Hardening Finished ######\n\n ###### Please do a restart #######";

sub system_update {
my $log_directory = "/root/secure.log";
mkdir "/root/secure_log" unless -e $log_directory ;
open LOG, ">", "/root/secure_log/step1.log";
my @update_log = `yum -y update`;
print LOG @update_log;
print LOG "############################################\n";
print LOG "Below is /var/log/ log for us to check after yum update\n#\n";
#After Updating the system check the error output.
opendir VARLOG, "/var/log";
my @check_log_date = split /\s+/, scalar localtime;
my @log_to_read = readdir VARLOG;
@log_to_read = map "/var/log/" . "$_", @log_to_read;
for (@log_to_read) {
next if -d;
open LOGREAD, $_;
while () {
if ($_ =~ /$check_log_date[1] $check_log_date[2]/) {
if ( $_ =~ /(crit|alert|error|warn)/i) {
print LOG "$_";
}
}

}
close LOGREAD;
}
close VARLOG;
close LOG;
# Set to check log file manually, exit and rerun
open RUNNED, ">", "/root/secure_log/runned";
print RUNNED "Step 1 Completed";
close RUNNED;
print "###### Check /root/secure_log/step1.log for error messages and rerun the program ##########\n";
exit;
}

sub system_ssh_hardening {
my ($admin_user,$ssh_port,$p_key_option);
# Adding Username to Wheel Group
print "\nEnter Username to add to admin : ";
chomp ($admin_user = );
system "useradd -m $admin_user";
system "usermod -G wheel $admin_user";
system "passwd $admin_user";
# Securing SSH.
rename "/etc/ssh/ssh_config", "/etc/ssh/ssh_config.backup";
open SSH, ">" , "/etc/ssh/ssh_config" or die "Cant open ssh_config";
open SSHREAD, "/etc/ssh/ssh_config.backup";
while () {
print SSH "$_";
print SSH "Protocol 2\nPort 22\n" if $_ =~/^Host */;
}
close SSHREAD;
close SSH;

# Securing SSHD
rename "/etc/ssh/sshd_config", "/etc/ssh/sshd_config.backup";
open SSHD, ">" , "/etc/ssh/sshd_config" or die "Cant open sshd_config";
open SSHDREAD, "/etc/ssh/sshd_config.backup" or die "Cant open sshd_config.backup";

#SSHD Option
print "\nEnter SSH Port to listen to [ default 22]: ";
chomp ($ssh_port = );
$ssh_port = 22 unless ( $ssh_port =~ /\d+/ );
print "\nDo you want to disable password and use private key only ? [Y/N] default no: ";
chomp ($p_key_option = );
$p_key_option = "1″ if $p_key_option =~ /(y|yes|Y|Yes|YES)/;

while () {
#Erase Previous Configuration
s/^(\s+)?Port (\d+)//;
s/^(\s+)?Protocol (.+)//;
s/^(\s+)?LogLevel (\w+)//;
s/^(\s+)?PermitRootLogin (\w+)//;
s/^(\s+)?RhostsRSAAuthentication (\w+)//;
s/^(\s+)?HostbasedAuthentication (\w+)//;
s/^(\s+)?IgnoreRhosts (\w+)//;
s/^(\s+)?PermitEmptyPasswords (\w+)//;
s/^(\s+)?Banner (.+)//;
s/^(\s+)?PasswordAuthentication (.+)// if $p_key_option eq "1″;
#Add The Configuration
s/^(\s+)?#(\s+)?Port (\d+)/Port $ssh_port/;
s/^(\s+)?#(\s+)?Protocol (.+)/Protocol 2/;
s/^(\s+)?#(\s+)?LogLevel (\w+)/LogLevel VERBOSE/;
s/^(\s+)?#(\s+)?PermitRootLogin (\w+)/PermitRootLogin no/;
s/^(\s+)?#(\s+)?RhostsRSAAuthentication (yes|no)/RhostsRSAAuthentication no/;
s/^(\s+)?#(\s+)?HostbasedAuthentication (\w+)/HostbasedAuthentication no/;
s/^(\s+)?#(\s+)?IgnoreRhosts (\w+)/IgnoreRhosts yes/;
s/^(\s+)?#(\s+)?PermitEmptyPasswords (\w+)/PermitEmptyPasswords no/;
s/^(\s+)?#(\s+)?Banner (.+)/Banner \/etc\/issue.net/;
s/^(\s+)?#(\s+)?PasswordAuthentication (.+)/PasswordAuthentication no/ if $p_key_option eq "1″;
print SSHD "$_";
}
close SSHD;
close SSHDREAD;
link "/root/secure_log/runned", "/root/secure_log/runned.ssh";
chown 0,0,"/etc/ssh/ssh_config";
chown 0,0,"/etc/ssh/sshd_config";
chmod 0644,"/etc/ssh/ssh_config";
chmod 0600,"/etc/ssh/sshd_config";
print "Do not Forget to add your public key to /home/$admin_user/.ssh/authorized_keys\n" if $p_key_option eq "1″;

# Modify Default Iptables version to the new SSH port.
if ($ssh_port != 22) {
rename "/etc/sysconfig/iptables", "/etc/sysconfig/iptables.backup";
open FIREWALLW, ">", "/etc/sysconfig/iptables";
open FIREWALL, "/etc/sysconfig/iptables.backup";
while () {
s/–dport 22/–dport $ssh_port/;
print FIREWALLW "$_";
}
close FIREWALLW;
close FIREWALL;

}

}

sub system_services {
my @service_xinetd = qw /amanda chargen chargen-udp cups cups-lpd daytime daytime-udp echo echo-udp eklogin ekrb5-telnet finger gssftp imap imaps
ipop2 ipop3 klogin krb5-telnet kshell ktalk ntalk rexec rlogin rsh rsync talk tcpmux-server telnet tftp time-dgram time-stream uucp /;
for (@service_xinetd) {
if (-e "/etc/xinetd.d/$_") {
system "chkconfig $_ off";
}
}
my @service_2 = qw / acpid amd anacron apmd arptables_jf aprwatch atd autofs avahi-daemon avahi-dnsconfd bpgd
bluetooth bootparamd capi conman cups cyrus-imapd dc_client dc_server dhcdbd dhcp6s dhcpd dhcrelay dovecot dund
firstboot gpm haldaemon hidd hplip httpd ibmasm ip6tables
ipmi irda iscsi iscsid isdn kadmin kdump kprop krb524 krb5kdc kudzu ldap lisa lm_sensors mailman mcstrans
mdmonitor mdmpd microcode_ctl multipathd mysqld named netfs netplugd NetworkManager nfs nfslock nscd ntpd openibd
ospf6d ospfd pand pcscd portmap postgresql privoxy psacct radvd rarpd rdisc readahead_early readahead_later rhnsd ripd
ripngd rpcgssd rpcidmapd rpcsvcgssd rstatd rusersd rwhod saslauthd setroubleshoot smartd smb snmpd snmptrapd spamassassin
squid tog-pegasus tomcat5 tux winbind wine wpa_supplicant xend xendomains ypbind yppasswdd ypserv ypxfrd zebra /;

for (@service_2) {
if (-e "/etc/init.d/$_") {
system "service $_ stop";
system "chkconfig –level 12345 $_ off";
}
}
}

sub system_user_account {

# Modify Admin_user for sudo

rename "/etc/sudoers", "/etc/sudoers.backup";
open SUDOERS, "/etc/sudoers.backup";
open SUDOERSW, ">", "/etc/sudoers";
while () {
s/^#(?:\s+)\%wheel(?:\s+)?ALL=\(ALL\)(?:\s+)ALL/\%wheel ALL=(ALL) ALL/i;
print SUDOERSW $_;
}
chmod 0440,"/etc/sudoers";
chown 0,0,"/etc/sudoers";
close SUDOERS;
close SUDOERS;

# Allow only group wheel to su.

rename "/etc/pam.d/su", "/etc/pam.d/su.backup";
open SU, ">", "/etc/pam.d/su";
open SUER, "/etc/pam.d/su.backup";
while (){
s/^#(?:\s+)?auth(?:\s+)?required(?:\s+)?pam_wheel.so(?:\s+)?use_uid/auth required pam_wheel.so use_uid/i;
print SU $_;
}
close SU;
close SUER;

# Configure User Account
# Maximum Age of password set to 60 days.
# Enforce password using 1 Upercase 1 lowercase 1 digit and 1 sign
# Enforce Length of Password = 9
rename "/etc/login.defs", "/etc/login.defs.backup";
open LOGINW, ">" , "/etc/login.defs";
open LOGIN, "/etc/login.defs.backup";
while () {
s/^(?:\s+)?PASS_MAX_DAYS(?:\s+)?(?:\d+)?/PASS_MAX_DAYS 60/i;
s/^(?:\s+)?PASS_MIN_DAYS(?:\s+)?(?:\d+)?/PASS_MIN_DAYS 0/i;
s/^(?:\s+)?PASS_MIN_LEN(?:\s+)?(?:\d+)?/PASS_MIN_LEN 9/i;
s/^(?:\s+)?PASS_WARN_AGE(?:\s+)?(?:\d+)?/PASS_WARN_AGE 7/i;
print LOGINW "$_";
}
close LOGINW;
close LOGIN;

# Configure PAM cracklib to include uppercase lowercase number and sign for password
# min len set to 9;

rename "/etc/pam.d/system-auth-ac", "/etc/pam.d/system-auth-ac.backup";
open PAMW, ">", "/etc/pam.d/system-auth-ac";
open PAM, "/etc/pam.d/system-auth-ac.backup";
while () {
s/^(?:\s+)?password(?:\s+)?requisite(?:\s+)?pam_cracklib.so(?:\s+)?try_first_pass(?:\s+)?retry=3/password requisite pam_cracklib.so try_first_pass retry=3 dcredit=-1 lcredit=-1 ocredit=-1 ucredit=-1 minlen=9/i;
print PAMW "$_";
}
close PAMW;
close PAM;

# Create running option
link "/root/secure_log/runned", "/root/secure_log/runned.user.account";
}

sub further_hardening {
my ($owner);
print "##### Installing System Accounting\n";
system "yum -y install sysstat";

##### Banner Creation #######

print "##### Creating Banner\n";
print "Enter Your Company Name : ";
chomp ($owner = );
open BANNER, ">", "/etc/issue";
print BANNER "\n NOTICE TO USERS\n —————–\n
This computer system is private property of $owner, Whether
individual, corporate or government. It is for authorized use only. Users
(authorized & unauthorized) have no explicit/implicit expectation of privacy
Any or all uses of this system and all files on this system may be
intercepted, monitored, recorded, copied, audited, inspected, and disclosed
to your employer, to authorized site, government, and/or law enforcement
personnel, as well as authorized officials of government agencies, both
domestic and foreign.\n
By using this system, the user expressly consents to such interception,
monitoring, recording, copying, auditing, inspection, and disclosure at the
discretion of such officials. Unauthorized or improper use of this system
may result in civil and criminal penalties and administrative or disciplinary
action, as appropriate. By continuing to use this system you indicate your
awareness of and consent to these terms and conditions of use. LOG OFF
IMMEDIATELY if you do not agree to the conditions stated in this warning.\n\n";
close BANNER;
copy "/etc/issue", "/etc/motd";
open BANNER1, ">", "/etc/issue.net";
print BANNER1 "\n##### Authorized USED ONLY ########\n\n";
close BANNER1;

# Configure AIDE System Checker
print "\n#Installing AIDE system Integerity#\n";
system "yum -y install aide";
system "/usr/sbin/aide –init";
copy "/var/lib/aide/aide.db.new.gz", "/var/lib/aide/aide.db.gz";
print "## Dont forget to check system Integerity by using /usr/sbin/aide –check";
#Closed Function
link "/root/secure_log/runned", "/root/secure_log/runned.further";
}