#!/bin/bash
#
# Copyright © 2020 Andrea Monti. All rights reserved.
# These scripts come without warranty of any kind. Use them at your own risk. 
# I assume no liability for the accuracy, correctness, completeness, or 
# usefulness of any information provided by this files nor for any sort of 
# damages using these scripts may cause.
#
# date:     2020-04-09
# version:  2.7
# history:
# 2019-10-02   MontiA    creazione
# 2019-10-07   MontiA    fix minori
# 2019-10-25   MontiA    aggiunta scrittura di mainlog e controllo log
# 2019-11-05   MontiA    aggiunto . ../lib/set_os_dependant_variables.sh, gestione di output
# 2019-11-25   MontiA    modificato file rman_ORCL_1year.rcv, corretti refusi
# 2020-02-25   MontiA    aggiunte informazioni su versione e patch
# 2020-04-06   MontiA    added print*info scripts,
# 2020-04-09   MontiA    spellchecking, neated
#
# description:
# this script start rman to execute the same-name command file
# to execute an incremental level 0 (full) backup
#


# set_os_dependant_variables sets variables which must differ on different
# *nix systems (i.e. awk full path, FQDN, ...)

. `dirname $0`/../lib/set_os_dependant_variables.sh


DATE_START=`date +%F_%H:%M:%S`

# buils the lof file path
LOG_FILE=$( . `dirname $0`/../lib/build_log_file_name.sh )
touch ${LOG_FILE}
export LOG_FILE


# when running bash on Linux, this trick willuse back exec and tee to
# redirect both stsdout and stderr to console output and log file
# at the same time. On different *nix OSes, I will only redirect both
# stdout and stderr to log file and I will cat it at the end
if [[ $( uname ) == "Linux" ]]
then
  exec &> >(tee -a "${LOG_FILE}")
else
  exec 6>&1            ## save stdout linking it to file desriptor 6
  exec 7>&2            ## save stderr linking it to file desriptor 7
  exec >> ${LOG_FILE}  ## redirects all stdout to ${LOG_FILE}
  exec 2>&1            ## redirects all stderr to stdout
fi


echo "========================================================================"
echo "start at `date` on ${HOSTNAME_FQDN}"
echo "logging in ${LOG_FILE}"
echo


# file ${HOME}/.${ORACLE_UNQNAME}.profile contains all Oracle configuration
# (i.e. ORACLE_SID, ORACLE_HOME, PATH, RMAN catalog connect string, ...)

export ORACLE_UNQNAME=ORCL
FILE_CONF=${HOME}/.${ORACLE_UNQNAME}.profile
if [[ ! -f ${FILE_CONF} ]] ; then echo "unable to find profile file ${FILE_CONF}" ; exit 1 ; fi
. ${FILE_CONF}

# if variables RMANUSER, RMANUSERPW, RMAN_INSTANCE are not set,
# I will use default values:

if [[ -z ${RMANUSER}      ]] ; then RMANUSER=RMANCAT_${ORACLE_UNQNAME};   fi
if [[ -z ${RMANUSERPW}    ]] ; then RMANUSERPW=RMANCAT_${ORACLE_UNQNAME}; fi
if [[ -z ${RMAN_INSTANCE} ]] ; then RMAN_INSTANCE=RMANCAT;                fi


# print_*sh scripts only print out informations about OS and Oracle Software
`dirname $0`/../lib/print_os_info.sh
`dirname $0`/../lib/print_oracle_home_info.sh


echo rman target / catalog ${RMANUSER}/XXXXXXXX@${RMAN_INSTANCE} cmdfile=\"`dirname $0`/rman_${ORACLE_UNQNAME}_level0.rcv\"
rman target / catalog ${RMANUSER}/${RMANUSERPW}@${RMAN_INSTANCE} cmdfile=\"`dirname $0`/rman_${ORACLE_UNQNAME}_level0.rcv\"
RETCODE=$?


# check whether the log file contains RMAN-xxxxx messages, even if rman's retcode is fine 
if [[ ${RETCODE} -eq 0 ]] ; then
  echo
  echo "looking for ^RMAN-xxxxx messages in log file..."
  echo
  egrep -q "^RMAN-([0-9]){5}" ${LOG_FILE}
  if [[ $? -eq 0 ]] ; then
    RETCODE=2
    echo "ERROR(s) found:"
    egrep "^RMAN-([0-9]){5}" ${LOG_FILE}
    echo
  else
    echo "no RMAN-xxxxx messages in log file"
  fi
fi


echo 
echo "RMAN ended with return code ${RETCODE} at `date`" 
echo "======================================================================" 


# perform end-of-task common action (i.e. mail the log, ...)
`dirname $0`/../lib/end_of_task_actions.sh


# restore stdout and stderr file descriptors
if [[ $( uname ) != "Linux" ]]
then
  exec 1>&6 6>&-   ## restore stdout and close file descriptor 6
  exec 2>&7 7>&-   ## restore stderr and close file descriptor 7
  cat ${LOG_FILE}
fi


exit ${RETCODE}

