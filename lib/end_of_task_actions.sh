#!/bin/bash

# Copyright © 2020 Andrea Monti. All rights reserved.
# These scripts come without warranty of any kind. Use them at your own risk. 
# I assume no liability for the accuracy, correctness, completeness, or 
# usefulness of any information provided by this files nor for any sort of 
# damages using these scripts may cause.

# perform end-of-task common action (i.e. mail the log, ...)
# leve empty or commented if not needed

# if [[ ${RETCODE} -eq 0 ]] ; then MESSAGE="SUCCESSFULL"; else MESSAGE="ERROR" ; fi
# DATE_END=`date +%F_%H:%M:%S`
# echo "${HOSTNAME_FQDN}, ${ORACLE_SID}, $(ps -o args= -p $PPID), ${LOG_FILE}, ${DATE_START}, ${DATE_END}, ${MESSAGE}" >> ${HOME}/scripts/mainlog.log
