#!/bin/bash

if [[  $# -eq 0 ]]; then                        # If no arguments are given to the script
   echo "Usage:                             # then print a usage statement and exit
   generate_config.sh hostname ip
   "
   exit 0;
fi

host="$1"
ip="$2"

echo "
# Define a host for the cacti-a machine

define host{
        use                     linux-server            ; Name of host template to use
                                                        ; This host definition will inherit all variables that are defined
                                                        ; in (or inherited by) the linux-server host template definition.
        host_name               $host
        alias                   webserver
        address                 $ip
        }

###############################################################################
###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################
###############################################################################

# Define a service to "ping" the cacti-a machine

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
        }

# Define a service to check HTTP on the cacti-a machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             HTTP
        check_command                   check_http
        notifications_enabled           0
        }

# Define a service to check the disk space of the root partition
# on the cacti-a machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             Root Partition
        check_command			              check_nrpe!check_disk!20%!10%!
	}

# Define a service to check the number of currently logged in
# users on the cacti-a machine.  Warning if > 20 users, critical
# if > 50 users.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             Current Users
        check_command			              check_nrpe!check_users!20!50
  }


# Define a service to check the number of currently running processes
# on the cacti-a machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             Total Processes
        check_command			              check_nrpe!check_procs!250!400!RSZDT
  }

# Define a service to check the load on the cacti-a machine.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             Current Load
        check_command			              check_nrpe!check_load!5.0,4.0,3.0!10.0,6.0,4.0
	}

# Define a service to check SSH on the cacti-a machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service{
        use                             generic-service         ; Name of service template to use
        host_name                       $host
        service_description             SSH
        check_command			              check_ssh
        notifications_enabled		        0
	}

# define service to check memory usage

define service{
        use                            generic-service
        host_name                      $host
        service_description            Check RAM
        check_command                  check_nrpe!check_mem
	}
">"$host".cfg
