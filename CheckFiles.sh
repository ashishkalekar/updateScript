#!/bin/bash
filePathFromBK=$PWD/backup/scripts
PATHTOSCRIPT=/opt/scripts
PATHTOMULE=/opt/mule

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
				echo "CheckSum are same for $filePathFromBK/$file"
			else 
				cp $PWD/backup/scripts/$file $PATHTOSCRIPT
							if [ $? -eq 0 ]; then
								echo File copying Completed.
							else
								echo File copying failed. Tring to restore backup.
							restoreBakup		
							fi
			fi	
		else
		echo "$file Not Found in $PATHTOSCRIPT"
		cp $PWD/backup/scripts/$file $PATHTOSCRIPT
		echo "$file Copping to $PATHTOSCRIPT"
    	fi	
done



