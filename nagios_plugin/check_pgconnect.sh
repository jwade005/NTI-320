#!/bin/bash

# nagios plugin to check postgresql connections

# Nagios States
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

WARN_THRESHOLD=50
CRITICAL_THRESHOLD=100

CONNECTIONS=`/bin/netstat -an | /bin/awk '{print $4}' | /bin/grep 5432 | /usr/bin/wc -l`

if [ ${CONNECTIONS} -gt ${CRITICAL_THRESHOLD} ]
  then
      echo "CRITICAL: Postgresql Connections are high: ${CONNECTIONS}!!"
      exit ${STATE_CRITICAL}

  else
      if [ ${CONNECTIONS} -gt ${WARN_THRESHOLD} ]

        then
          echo "WARNING: Postgresql Connections are getting high: ${CONNECTIONS}!!"
          exit ${STATE_WARNING}

        else
          echo "OK: Postgresql Connections are at:  ${CONNECTIONS}"
          exit ${STATE_OK}

      fi

fi
