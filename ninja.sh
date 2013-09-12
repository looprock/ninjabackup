#!/bin/sh

# version: 0.0.4

source /etc/ninja.conf

children=2
rm -rf ${tmpdir}/folder.*
newconf="${tmpdir}/${bacconfname}"
cp -R ${bacconfpath}/${bacconfname} ${tmpdir}/
allfiles=`ls ${newconf}/*.conf|wc -l`
blah=$((allfiles / $children))
plusone=$((blah + 1))
#echo "processing $plusone configs per 'thread'"

loopcount=0
while [ ${loopcount} -lt ${children} ]
do 
 loopcount=`expr $loopcount + 1`
 #echo "Loopcount: ${loopcount}"
 newfolder=${tmpdir}/folder.${loopcount}
 #echo "processing ${newfolder}"
 mkdir ${newfolder}
 #echo "for i in `ls ${newconf}/*.conf |head -${plusone}`"
 for i in `ls ${newconf}/*.conf |head -${plusone}`
 do
   #echo "mv ${i} ${newfolder}/"
   mv ${i} ${newfolder}/
 done
 #echo "cp ${newconf}/*.txt ${newfolder}/"
 cp ${newconf}/*.txt ${newfolder}/
done

logID=0
while [ ${logID} -lt ${children} ]
do
 logID=`expr $logID + 1`
 nohup /sbin/ninjabackup split ${tmpdir}/folder.${logID} ${logID} 2>&1 > ${tmpdir}/ninja.${logID}.out &
done

wait
cat ${tmpdir}/ninjabackup-* >> ${BUCKEDIR}/logs/ninjabackup-${BUCKDATE}.log
# rm -f ${tmpdir}/ninjabackup-*
/sbin/ninjakill

rm -rf ${newconf}
exit 0
