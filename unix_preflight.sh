#!/bin/sh
# Chef pre-flight test script for Linux and OSX machines
# vim: ai ts=2 sw=2 et sts=2 ft=sh
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=sh

# Set these for colorized output
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

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

echo "Checking connectivity to Internet sites..."

col=30
for site in ${sites[*]}; do
  if [ "$(curl -s $site)" ]; then
    printf '%-40s%*s%s\n' "Checking $site" $col "${green}[OK]${normal}"
  else
    printf '%-40s%*s%s\n' "Checking $site" $col "${red}[FAIL]${normal}"
  fi
done
