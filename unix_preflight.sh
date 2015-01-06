#!/bin/sh
# Chef pre-flight test script for Linux and OSX machines
# vim: ai ts=2 sw=2 et sts=2 ft=sh
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=sh

# Prerequisites:  
# CentOS:  bind-utils, nc
# Ubuntu:  dnsutils, netcat

# Set these for colorized output
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

# Do I have local admin rights?
[ "$(sudo -l | grep \(ALL\))" ] && hazadmin=true

# Can I reach these Internet sites
sites=(\
  google.com \
  aws.amazon.com \
  cloud.google.com \
  rackspace.com \
  azure.microsoft.com \
  manage.chef.io \
  use.cloudshare.com \
  supermarket.chef.io \
  api.chef.io \
  rubygems.org
)

echo
echo "###############################################################################"
echo "Testing DNS resolvers..."
echo "###############################################################################"
col=30
for site in ${sites[*]}; do
  dig $site 2>&1 >/dev/null
  if [ $? -eq 0 ]; then
    printf '%-40s%*s%s\n' "Checking DNS for $site" $col "${green}[OK]${normal}"
  else
    printf '%-40s%*s%s\n' "Checking DNS for $site" $col "${red}[FAIL]${normal}"
  fi
done

echo
echo "###############################################################################"
echo "Checking connectivity to Internet sites..."
echo "###############################################################################"

col=30
for site in ${sites[*]}; do
  curl -s $site 2>&1 >/dev/null
  if [ $? -eq 0 ]; then
    printf '%-40s%*s%s\n' "Checking $site" $col "${green}[OK]${normal}"
  else
    printf '%-40s%*s%s\n' "Checking $site" $col "${red}[FAIL]${normal}"
  fi
done
