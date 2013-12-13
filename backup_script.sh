#!/bin/bash

######################################################################
# Made By xInit Team
# Khouili Chiheb  
# Hmidi Hend	 
# Dkhili Hend	 
# Ochi Amani	 
# Maatoug Mourad
######################
# Version	 : 1.0
# LICENSE	 : GPLv3
#####################################################################


######################################################################
# Script Backup Configuration
# Parent backup directory
BACKUP_PARENT_DIR="/backupdir"
# Backup script file log name
SCRIPT_LOG_FILE=backUpScript_`date +%d-%m-%Y_%H-%M`
echo "[Info] - Cheking Directory : ${BACKUP_PARENT_DIR}"
if ! [ -d "$BACKUP_PARENT_DIR" ]; then
        echo "[Info] - Creating Backup Directory : ${BACKUP_PARENT_DIR}"
        mkdir $BACKUP_PARENT_DIR
fi

echo "[Info] - Cheking Backup Script Log File"
if ! [ -f "$BACKUP_PARENT_DIR/$SCRIPT_LOG_FILE.log" ]; then
        echo "[Info] - Creating Backup Script Log File"
        touch ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
fi

######################################################################
# Logging Script Start
DATE=`date +%d/%m/%Y_%H-%M`
echo "------------------------------------------------------------------------" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
echo "[Info] - Starting backup Script at ${DATE}" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log

######################################################################
# Directories to backup
# Support More than one directory just add what you want separated by space " "
BACKUP_ME="/home"
MAX_BACKUP=5 

######################################################################
# FTP Setting Part
# Want to send backup to FTP Server or NO 
SEND_TO_FTP="yes"
# FTP Connection Information
HOST="127.0.0.1"
LOGIN="backup_user"
PASSWORD="esprit_backup"
PORT=21
######################################################################

# Check if root is running the script or no 
if [[ $UID  != 0 ]]; then
        echo "[Info] - Must be run as root"
        exit 1
fi

# Check and create backup directory
BACKUP_DATE=`date +%d-%m-%Y_%H-%M`
BACKUP_DIR=${BACKUP_PARENT_DIR}/fs_${BACKUP_DATE}
echo "[Info] - Creating Backup Directory :  ${BACKUP_DIR}"
echo "[Info] - Creating Backup Directory :  ${BACKUP_DIR}" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
mkdir -p $BACKUP_DIR

# Get number of backup made
BACKUP_NUMBER=`ls -l ${BACKUP_PARENT_DIR}| grep ^d | wc -l`
echo "[Info] - Cheking Number of backup [ ${BACKUP_NUMBER} ]"
echo "[Info] - Cheking Number of backup [ ${BACKUP_NUMBER} ]" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log

# Cheking if Max Number of Backups is reatched 
if [ "$BACKUP_NUMBER" -gt "$MAX_BACKUP" ];
then
        echo "[Info] - Deleting oldest Backup files"
        echo "[Info] - Deleting oldest Backup files" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
        # Get oldest BackUp Name
        cd ${BACKUP_PARENT_DIR}
        OLDEST_BACKUP=`ls -lt | grep ^d | tail -1  | tr " " "\n" | tail -1`
        echo "[Info] - Deleting oldest Backup files ${OLDEST_BACKUP}" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
        rm -R ${OLDEST_BACKUP}
fi

echo "[Info] - Starting Backup instruction"
echo "[Info] - Starting Backup instruction" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
# Start BackUp Procedure
for directory in $BACKUP_ME
do
        archive_name=`echo ${directory} | sed s/^\\\/// | sed s/\\\//_/g`
        touch ${BACKUP_DIR}/${archive_name}.log
        tar pcfzP ${BACKUP_DIR}/${archive_name}.tgz ${directory} 2>&1 | tee > ${BACKUP_DIR}/${archive_name}.log
done

echo "[Info] - Backup done and saved to ${BACKUP_DIR}"
echo "[Info] - Backup done and saved to ${BACKUP_DIR}" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log

if [ "$SEND_TO_FTP" = "yes" ]; then
        # Compressing Back Up files and log
        echo "[Info] - Compressing ${BACKUP_DIR} Directory to ${BACKUP_PARENT_DIR}/tmp_${BACKUP_DATE}.tgz"
        echo "[Info] - Compressing ${BACKUP_DIR} Directory to ${BACKUP_PARENT_DIR}/tmp_${BACKUP_DATE}.tgz" >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
        tar pcfzP ${BACKUP_PARENT_DIR}/tmp_${BACKUP_DATE}.tgz ${BACKUP_DIR} 2>&1 | tee > /dev/null
        echo "[FTP] - Sending file to FTP Server"
        echo "[FTP] - Sending file to FTP Server"  >> ${BACKUP_PARENT_DIR}/${SCRIPT_LOG_FILE}.log
        # Uploading Backup to FTP Server
ftp -i -n $HOST $PORT << EOF
quote USER $LOGIN
quote PASS $PASSWORD
pwd
bin
put ${BACKUP_PARENT_DIR}/tmp_${BACKUP_DATE}.tgz $(hostname -s)_${BACKUP_DATE}.tgz
quit
EOF
rm ${BACKUP_PARENT_DIR}/tmp_${BACKUP_DATE}.tgz

fi

