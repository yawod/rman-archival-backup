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
#
# description:
# this script prints oracle_home informations
# (i.e. version, patches, components) 
#


echo
echo ORACLE_SID=${ORACLE_SID}

echo
echo ORACLE_HOME informations:
echo ORACLE_HOME=${ORACLE_HOME}
sqlplus -V

echo
echo "Patches (from opatch lspatches):"
${ORACLE_HOME}/OPatch/opatch lspatches

echo
echo Installed options:
for opt in $( ar -t ${ORACLE_HOME}/rdbms/lib/libknlopt.a )
do
  case $opt in
    kfon.o)     echo "ASM ON"                  ;;
    kfoff.o)    echo "ASM OFF"                 ;;
    kciwcx.o)   echo "CTX-ConText ON"          ;;
    kcincx.o)   echo "CTX-ConText OFF"         ;;
    dmwdm.o)    echo "DM-Data Mining ON"       ;;
    dmndm.o)    echo "DM-Data Mining OFF"      ;;
    kzvidv.o)   echo "DV-Database Vault ON"    ;;
    kzvndv.o)   echo "DV-Database Vault OFF"   ;;
    xsyeolap.o) echo "OLAP ON"                 ;;
    xsnoolap.o) echo "OLAP OFF"                ;;
    kzlilbac.o) echo "OLS-Label Security ON"   ;;
    kzlnlbac.o) echo "OLS-Label Security OFF " ;;
    kkpoban.o)  echo "Partitioning ON"         ;;
    ksnkkpo.o)  echo "Partitioning OFF"        ;;
    kcsm.o)     echo "RAC ON"                  ;;
    ksnkcs.o)   echo "RAC OFF"                 ;;
    kzaiang.o)  echo "Unified Auditing ON"     ;;
    kzanang.o)  echo "Unified Auditing OFF"    ;;
    kecwr.o)    echo "RAT ON"                  ;;
    kecnr.o)    echo "RAT OFF"                 ;;
    *)          echo " unknown option $opt"    ;;
  esac
done | sort

echo
echo "database components (from dba_registry):"
sqlplus -L -S / as sysdba <<eof1
set linesize 100
set trimspool on
column comp_name format a58
column version   format a20
column status    format a20
select banner from v\$version ;
set feedback on
select comp_name, version, status from dba_registry order by 1 ;
exit
eof1

echo
echo "patches installed (from dba_registry_sqlpatch, dba_registry_history):"
sqlplus -S -L / as sysdba <<eof2
set linesize 120
set feedback on
column action format a10
column status format a12
column description format a70

select patch_id, action, status, description
 from  DBA_REGISTRY_SQLPATCH
 order by action_time;

select nvl2(version, version || nvl2(id,'.' || id, '') , id) as patch_id, action, comments
 --  , v.*
 from  dba_registry_history v 
 order by v.action_time nulls first, v.comments, v.action, v.version, v.id;

exit

eof2

