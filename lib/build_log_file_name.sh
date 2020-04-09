# Copyright © 2020 Andrea Monti. All rights reserved.
# These scripts come without warranty of any kind. Use them at your own risk. 
# I assume no liability for the accuracy, correctness, completeness, or 
# usefulness of any information provided by this files nor for any sort of 
# damages using these scripts may cause.

# date:     2020-04-09
# version:  2.7
# history:
# 2019-10-02   MontiA    created
#
# description:
# this script build a log file full path starting from the current 
# command  (i.e. from $0 )
# This script does not start with any shabang as it should be called
# "in line" to properly read $0
# Log file name will be build as follow:
#  - will be in subdirectory "logs"
#  - will start with script filename
#  - will not contain script filename's extension
#  - will not contain non-ASCII or non-printable characters
#  - will containt current date and time 
#  - will containt process PID
#  - will contain (if present) command line arguments


# use the right AWK: on Solaris, use /usr/xpg4/bin/awk rather than default awk
if [[ $(uname) == "SunOS" ]] && [[ -f /usr/xpg4/bin/awk ]]
then
  AWK=/usr/xpg4/bin/awk
else
  AWK=`which awk`
fi


# save script directory in CUR_SCRIPT_DIR variable  
cd `dirname $0`
CUR_SCRIPT_DIR=${PWD}
cd - >/dev/null


# get the script name. If we are running 
#  - ./filename.script.sh 
#  - /path/to/script_filename.ksh
#  - ./script_with_no_extension
# I will end up with:
#  - filename.script
#  - script_filename
#  - script_with_no_extension

# remove path if present 
SCRIPT_FILENAME_TEMP=`echo $0 | ${AWK} -F"/" ' { if( NR>0 ) { print $NF } else { print } }'`

# remove filename extension, if present leaving the final "."
SCRIPT_FILENAME_TEMP=`echo ${SCRIPT_FILENAME_TEMP} | ${AWK} 'BEGIN{FS=".";OFS=".";ORS="."}; {if ( NF > 1 ) {for(i=1;i<NF;++i) print $i} else {print $1} }'`

# remove the final dot if present
SCRIPT_FILENAME_TEMP=`echo ${SCRIPT_FILENAME_TEMP} | sed 's/\.$//'`

# in case of problems, go back to the full file name
if [[ -z ${SCRIPT_FILENAME_TEMP} ]] ; then SCRIPT_FILENAME_TEMP="`echo $0 | ${AWK} -F"/" '{print $NF}'`" ; fi
if [[ -z ${SCRIPT_FILENAME_TEMP} ]] ; then SCRIPT_FILENAME_TEMP=$0; fi


# remove non-ASCII, non-printable characters, and set the variable SCRIPT_FILENAME
SCRIPT_FILENAME=`echo ${SCRIPT_FILENAME_TEMP} | tr -d [:space:]`
SCRIPT_FILENAME=`echo ${SCRIPT_FILENAME_TEMP} | tr -dc [:print:]`

export SCRIPT_FILENAME

# build the log file name
if [[ $# -gt 0 ]]
then
  ARGS=`echo $* | tr -dc [:print:] | tr [:space:] " " | tr -s [:space:] | tr [:space:] "_" | tr " " _`
  LOG_FILE=${CUR_SCRIPT_DIR}/logs/${SCRIPT_FILENAME}_${ARGS}.`date +%Y-%m-%d_%H-%M-%S`.$$.log
else
  LOG_FILE=${CUR_SCRIPT_DIR}/logs/${SCRIPT_FILENAME}.`date +%Y-%m-%d_%H-%M-%S`.$$.log
fi

echo ${LOG_FILE}

