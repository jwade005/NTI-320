#!/bin/bash

# postgresql plugin to check writing to a test db

# Nagios States
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

# create test database
