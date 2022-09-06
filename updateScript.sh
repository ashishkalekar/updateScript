#!/bin/bash
PATHTOSCRIPT=/opt/scripts
PATHTOMULE=/opt/mule
PATHTOSCRIPTBK=$PWD/backup/scripts
PATHTOMULEBK=$PWD/backup/mule
PATHTOSCRIPT1=/opt/scripts
#1) Backup old files
DB_BACKUP="/opt/backups/`date +%Y-%m-%d`"
# Create the backup directory
mkdir -p $DB_BACKUP
#function to restore bakup
function restoreBakup {
	unzip $DB_BACKUP/`date +%Y-%m-%d`.zip -d $DB_BACKUP
	if [ $? -eq 0 ]; then
             echo "[Info] : backuped files Unzip Completed."
        else
             echo "[Failed] : unzip failed!!!. Please Try manually OR coordinate with IT team."
        fi
	echo "[Info] : Removing all files to restore bakup"
	rm -r $PATHTOSCRIPT/* && rm -r $PATHTOMULE/*

	cp -r $DB_BACKUP/opt/scripts/* $PATHTOSCRIPT 
	if [ $? -eq 0 ]; then
             echo File copying from backup Completed.
        else
             echo "[Failed] : please Try copying manually OR coordinate with IT team."
        fi
	cp -r $DB_BACKUP/opt/mule/* $PATHTOMULE
	if [ $? -eq 0 ]; then
             echo "[Info] : File copying from bakcp Completed."
        else
             echo "[failed] : please Try copying manually OR coordinate with IT team."
        fi
}
#function for CheckFiles i.e md5CheckSum
function CheckFiles() {
	#echo $1;
	filePathFromBK=$1
	PATHTOSCRIPT=$2
	fileNamesFromBK=$(ls -1 $filePathFromBK/)
	fileNamesFromLocal=$(ls -1 $PATHTOSCRIPT/)
	for file in $fileNamesFromBK
	do
			if [[ -f $PATHTOSCRIPT/$file ]]
			then
				checkFromBk=`md5sum $filePathFromBK/$file | awk '{ print $1 }'`	
				checkFromLocal=`md5sum $PATHTOSCRIPT/$file | awk '{ print $1 }'`
		
				if [ "$checkFromBk" = "$checkFromLocal" ] 
				then
					echo "[Skip] : CheckSum are same for $filePathFromBK/$file and $PATHTOSCRIPT/$file"
				else 
					cp -r $filePathFromBK/$file $PATHTOSCRIPT
								if [ $? -eq 0 ]; then
									echo File copying from $filePathFromBK/$file to $PATHTOSCRIPT Completed.
								else
									echo File copying failed from $filePathFromBK/$file to $PATHTOSCRIPT. Tring to restore backup.
									restoreBakup		
								fi
				fi	
			else
				echo "[Info] :  $file Not Found in $PATHTOSCRIPT"
				cp -r $filePathFromBK/$file $PATHTOSCRIPT
				if [ $? -eq 0 ]; then
                         echo File copying from $filePathFromBK/$file to $PATHTOSCRIPT Completed.
                 else
                         echo File copying failed from $filePathFromBK/$file to $PATHTOSCRIPT. Tring to restore backup.
                         restoreBakup
                 fi
				echo "[Info] : $filePathFromBK/$file from $file Copping to $PATHTOSCRIPT"
			fi	
	done
	#exit
}
#To check Directory exists or not 
if [ -d "$PATHTOMULE" ] && [ -d "$PATHTOSCRIPT" ];
then
    echo "[=======================================================>] Working on bakup"
	zip -r $DB_BACKUP/`date +%Y-%m-%d`.zip $PATHTOSCRIPT $PATHTOMULE
	if [ $? -eq 0 ]; then
   		echo "[=======================================================>] Backup Completed"
		#Download bakup file
		wget http://44.207.7.204/backupV2.zip;
		if [ $? -eq 0 ]; then
		   echo Download Completed
			#unzip the file
		   unzip backupV2.zip
		   if [ $? -eq 0 ]; then
                echo unzip Completed
			CheckFiles $PATHTOMULEBK $PATHTOMULE;
				echo "[Info] : CheckFiles  complete for mule" 				
			CheckFiles $PATHTOSCRIPTBK $PATHTOSCRIPT1
				echo "[Info] : CheckFiles  complete for script" 
			echo ****************************************************Update Successfully Completed****************************************************
		   else
                   	echo unzip failed!!!
                   fi
		else
		   echo Download Failed!!!
		fi
	else
   		echo Bakup failed!!!
	fi 
else
    echo "[Error] : Directory Does Not exists."
fi

