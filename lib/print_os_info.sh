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
# 2020-04-06   MontiA    added print*info.sh
# 2020-04-08   MontiA    added process tree
#
#
# description:
# this script prints basic OS info 
# (i.e. OS name, kernel version, ...)
#


echo
echo "uname says: $( uname )"
echo "uname -a says: $( uname -a )"

echo
for etcfile in /etc/system-release /etc/oracle-release /etc/redhat-release /etc/SuSE-release 
do
  [[ -f ${etcfile} ]] && echo "file ${etcfile} contains: $( cat ${etcfile} )" || echo "file ${etcfile} missing"
done

echo
echo process tree follows:

print_ps_tree()
{
  if [[ ${1} -eq 1 ]]
  then
    ps -fp 1
  else
    ##echo debug-$1
    ##echo debug-print_ps_tree $( ps -fp $1 | tail -n 1 | tr -s [:space:]| cut -d " " -f 3 )
    print_ps_tree $( ps -fp $1 | tail -n 1 | tr -s [:space:]| cut -d " " -f 3 )
    ps -fp $1 | tail -n 1
  fi;
}

print_ps_tree $$

