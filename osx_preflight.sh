#!/bin/sh
# Chef pre-flight test script for OSX machines

# Set these for colorized output
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

# Are the XCode Developer Tools installed?
echo
echo "###############################################################################"
echo "Verifying XCode Developer Tools are Installed..."
echo 
xcode-select -p 2>&1 >/dev/null
col=40
if [ $? -eq 0 ]; then
  printf '%-50s%*s%s\n' "Checking for XCode Developer Tools" $col "${green}[OK]${normal}"
else
  printf '%-50s%*s%s\n' "Checking for XCode Developer Tools" $col "${red}[FAIL]${normal}"
fi

# Sanity Check: Do I have gcc and make?

# Define tools here to keep things DRY
tools=(\
  gcc \
  make
)

for tool in ${tools[*]}; do
  /usr/bin/which $tool 2>&1 >/dev/null
  col=40

  if [ $? -eq 0 ]; then
    printf '%-50s%*s%s\n' "Checking $tool" $col "${green}[OK]${normal}"
  else
    printf '%-50s%*s%s\n' "Checking $tool" $col "${red}[FAIL]${normal}"
  fi
done

# Now run the shared *nix stuff
./unix_preflight.sh