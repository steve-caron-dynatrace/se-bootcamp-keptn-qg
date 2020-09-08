#!/bin/bash
# =========================================================
#      -------- Keptn-in-a-Box -------                    #
# Script for installing Keptn in an Ubuntu Server LTS     #
# (20 or 18). Installed components are but not limited to:#
# Microk8s, Keptn, Istio, Helm, Docker, Docker Registry   #
# Jenkins, Dynatrace OneAgent, Dynatrace ActiveGate,      #
# Unleash, KeptnExamples                                  #
#                                                         #
# This file is the main installation process. In here you #
# define the installationBundles and its functions.       #
# The definition of variables and different versions are  #
# defined here.                                           #
#                                                         #
# 'functions.sh' is where the functions are defined and   #
# will be loaded into this shell upon execution.          #
# controlled via boolean flags.                           #
#                                                         #
# An installationBundle contains a set of multiple ins-   #
# tallation functions.                                    #
# =========================================================

# ==================================================
#      ----- Variables Definitions -----           #
# ==================================================
LOGFILE='/tmp/install.log'
touch $LOGFILE
chmod 775 $LOGFILE
pipe_log=true

# - The installation will look for this file locally, if not found it will pull it form github.
FUNCTIONS_FILE='functions.sh'

# ---- Workshop User  ---- 
# The flag 'create_workshop_user'=true is per default set to false. If it's set to to it'll clone the home directory from USER and allow SSH login with the given text password )
NEWUSER=bootcamp
INSTANCE_NO=$(hostname | grep -Eo '[0-9]+$')
NEWPWD=keptn$INSTANCE_NO-R0ck$

# ---- Define Dynatrace Environment ---- 
# Sample: https://{your-domain}/e/{your-environment-id} for managed or https://{your-environment-id}.live.dynatrace.com for SaaS
TENANT=
PAASTOKEN=
APITOKEN=

# ==================================================
#      ----- Functions Location -----                #
# ==================================================
FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/steve-caron-dynatrace/se-bootcamp-keptn-qg/0-Setup/functions.sh"

## ----  Write all output to the logfile ----
if [ "$pipe_log" = true ] ; then
  echo "Piping all output to logfile $LOGFILE"
  echo "Type 'less +F $LOGFILE' for viewing the output of installation on realtime"
  echo ""
  # Saves file descriptors so they can be restored to whatever they were before redirection or used 
  # themselves to output to whatever they were before the following redirect.
  exec 3>&1 4>&2
  # Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
  trap 'exec 2>&4 1>&3' 0 1 2 3
  # Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you 
  # want them going to the same file. stdout must be redirected before stderr is redirected to stdout.
  exec 1>$LOGFILE 2>&1
else
  echo "Not piping stdout stderr to the logfile, writing the installation to the console"
fi

# Load functions after defining the variables & versions
if [ -f "$FUNCTIONS_FILE" ]; then
    echo "The functions file $FUNCTIONS_FILE exists locally, loading functions from it. (dev)"
else 
    echo "The functions file $FUNCTIONS_FILE does not exist, getting it from github."
    curl -o functions.sh $FUNCTIONS_FILE_REPO
fi

# Comfortable function for setting the sudo user.
if [ -n "${SUDO_USER}" ] ; then
  USER=$SUDO_USER
fi
echo "running sudo commands as $USER"

# Wrapper for runnig commands for the real owner and not as root
alias bashas="sudo -H -u ${USER} bash -c"
# Expand aliases for non-interactive shell
shopt -s expand_aliases

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE

# ==================================================
#      ----- Override Components Versions -----    #
# ==================================================
#MICROK8S_CHANNEL="1.15/stable"
#KEPTN_IN_A_BOX_DIR="~/keptn-in-a-box"
#KEPTN_EXAMPLES_DIR="~/examples"
#KEPTN_IN_A_BOX_REPO="https://github.com/keptn-sandbox/keptn-in-a-box"
# ==================================================
#    ----- Select your installation Bundle -----   #
# ==================================================

installationBundleBootcampPrep

# ==================================================
# ---- Enable or Disable specific functions -----  #
# ==================================================
# -- Override a module like for example verbose output of all commands
#verbose_mode=false

# -- or install cert manager 
#certmanager_install=true
#certmanager_enable=true
#create_workshop_user=true

# ==================================================
#  ----- Call the Installation Function -----      #
# ==================================================
doInstallation

# Launch the simple node service running in container
docker run -p 8070:8080 grabnerandi/simplenodeservice:1.0.0
