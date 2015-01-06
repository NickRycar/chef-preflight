#!/bin/sh
# Chef pre-flight test script for Linux and OSX machines
# vim: ai ts=2 sw=2 et sts=2 ft=sh
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=sh

# Set these for colorized output
red='\033[1;31m'
green='\033[1;32m'
normal='\033[0m'

# Do I have local admin rights?
[ "$(sudo -l | grep \(ALL\))" ] && hazadmin=true

# Can I reach these Internet sites
sites=(\
  manage.getchef.com \
  use.cloudshare.com \
  supermarket.getchef.com \
  api.getchef.com \
  rubygems.org
)

# echo ${sites[*]}

echo "Checking connectivity to Internet sites..."

for site in ${sites[*]}; do
  if [ "$(curl -s $site)" ]; then
    #printf( "%-30s %s\n", "Checking $site ${green}[OK]${normal}" );
    echo test
  else
    echo "${red}[FAIL]${normal}"
  fi
done
