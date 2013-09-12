ninjabackup
===========

an embarrassing old rdiff-backup based set of scripts


The Ninja-Backup Primer
Version: 0.1
Author : Doug Land - Sept. 06, 2007


Install scripts:
copy ninja.sh, ninjabackup, and ninjakill to /sbin

configuring /etc/ninja.conf: 

BUCKEDIR - This is the location your rdiff-backups are stored
tmpdir - Temp directory
BCDIR - Location of client configs
BUCKDATE - the date
RDIFF - rdiff-backup binary
REPORTTO - who to send backup reports to
children - number of "child threads" to spawn, using the fake threading model, shouldn't be less than 2


/etc/ninja.conf sample:
BUCKEDIR="/export/backup"
tmpdir="${BUCKEDIR}/tmp"
BCDIR="/etc/backup.d"
BUCKDATE=`date '+%Y%m%d%H%M'`
RDIFF="/usr/bin/rdiff-backup"
REPORTTO="backup-admin@mail.yav4.com"
children=2

Client Configuration:

CLIENT - Typically a "short name" for the host and should match the file name with ".conf" at the end, i.e. TESTHOST.conf should start with an entry: CLIENT="TESTHOST". Valid characters == [0-9, a-Z, spaces, periods, underscores]
ADDRESS - Client's IP or FQDN
SYSTYPE - This define's the files/directories that are backed up. If there is no "CLIENT"-files.txt, this should be set to the fallback system class for the client, i.e. linux if you want to use the definition from linux-files.txt.

SAMPLE_CLIENT.conf:
CLIENT="SAMPLE_CLIENT"
ADDRESS="10.10.16.106"
SYSTYPE="linux"

The example above would back up all the files in linux-files.txt from 10.10.16.106 to /export/backup/SAMPLE_CLIENT (according to ninja.conf)
Say this is a developer's system where everything runs out of everyone's perspective home directories, you could get more specific, only backing up /home and /etc.

SAMPLE_CLIENT-files.txt:
/home
/etc
- /

Next, set up the ssh keys.  If you haven't already done so, make an ssh key pair. We should lock the key down as well, so I modify the .pub before I scp it:

from="212.118.234.202",command="rdiff-backup --server --restrict-read-only /",no-X11-forwarding,no-port-forwarding,no-pty ssh-dss AAAAB3NzaC1kc3MAAACBALr8GWCE/..etc..

where "from" is the backup server address, and scp the .pub key to the client as authorized_keys.

After you set up the key on the client, you should ssh from the server to the client to add the key to the known hosts:
ssh -v -v -v [value you used for ADDRESS in the client config]

you can test the backup at this point:
ninjabackup debug SAMPLE_CLIENT

There are a few options you can use with ninjabackup, but debug is really the only one you should be interested in for running, or re-running single backups:
all - process all logs in /etc/backup.d
run - back up a single host, requires shortname (i.e. [shortname].conf)
debug - run + print output, requires shortname (i.e. [shortname].conf)
split - this handles fake threading, requires arguments directory and log ID

After you've verified all the clients, as you add them and run the first backups, set up the cron job to fire off the backups nightly:
0 0 * * * /sbin/ninja.sh &


