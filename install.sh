#!/bin/bash

######################################################################
# Install wiazrd for Automted backup Script
######################################################################
# Made By xInit Team
# Khouili Chiheb  
# Hmidi Hend	 
# Dkhili Imen	 
# Ochi Amani	 
# Maatoug Mourad
######################
# Version	 : 1.0
# LICENSE	 : GPLv3
######################################################################

cp backup_script.sh /bin/backup_script.sh
chmod u+x /bin/backup_script.sh
if [ -f "/etc/crontab"]; then
	echo "#!/bin/bash" > /etc/cron.daily/daily_backup.sh
	echo "/bin/backup_script.sh" >> /etc/cron.daily/daily_backup.sh
else
	echo "Warning : cron does not exist !!"
fi

