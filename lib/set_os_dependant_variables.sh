# Copyright © 2020 Andrea Monti. All rights reserved.
# These scripts come without warranty of any kind. Use them at your own risk. 
# I assume no liability for the accuracy, correctness, completeness, or 
# usefulness of any information provided by this files nor for any sort of 
# damages using these scripts may cause.

# date:     2020-04-09
# version:  2.7
# history:
# 2020-04-09 MontiA    created
#
# description:
# This script does not start with any shabang as it should be called
# "in line" to properly set variables
#
# This script set variables which must differ on different *nix systems 
# to leave other scripts as neat as possible 

# use the right AWK: on Solaris use /usr/xpg4/bin/awk to leverage on the same syntax
if [[ $(uname) == "SunOS" ]] && [[ -f /usr/xpg4/bin/awk ]]
then
  AWK=/usr/xpg4/bin/awk
else
  AWK=`which awk`
fi

# set HOSTNAME_FQDN to have the full FQDN
if   [[ $(uname) == "AIX" ]] && [[   -z `domainname` ]]
then
  HOSTNAME_FQDN=`hostname`
elif [[ $(uname) == "AIX" ]] && [[ ! -z `domainname` ]]
then
  HOSTNAME_FQDN=`hostname`.`domainname`
else
  HOSTNAME_FQDN=`hostname -f`
fi
export HOSTNAME_FQDN

# check whether most commonly required commands are available 
for c in awk echo date dirname domainname egrep hostname tee touch tr uname ${AWK}
do
  which ${c} >/dev/null 2>&1
  if [[ $? -ne 0 ]]
  then
    echo ERROR: unable to find command "${c}"
  fi
done
