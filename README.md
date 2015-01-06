Customer responsibility:

Attendees, E-Mail Address, Role (i.e. sysadmin, developer, etc). It is critical to know who is attending, as we are going to verify that ALL attendees are setup properly with the following: (where do we store this information?)

Workstation:

* Do the users have local admin rights to install items to their systems?
  * If not, can they be granted?

Items necessary:

* chefDK
* Required Gems?  (Knife-windows, knife-push, etc)

Items recommended

* Vagrant
* Virtualbox
* Git (from git-scm.com) [Windows]

Are users behind a proxy or other restrictive firewall?
Verify web connectivity to:

* manage.getchef.com
* supermarket.getchef.com
* api.getchef.com
* rubygems.org

Verify ssh connectivity to:
* Outbound to AWS/Azure/DO/GCE
* Verify they can download and extract zip files from manage.getchef.com.

Recommended tests:
* Seth Vargo’s Connectivity Tester: https://github.com/sethvargo/chef-connectivity-test _base upon the outcome of these tests, not actually run this script itself_

* Download and install ChefDK
* Download starter kit from Hosted Chef.
* run: knife client list
* run chef gem install knife-push
* knife cookbook site download chef-client
* ssh to external web server (ideally cloudshare)

User Home directory (Windows)
* Make sure the user home directory is set to C drive (or fix issues associated)

Chef Server (If Customer is hosting their own, rather than using Hosted for POV)

* Do they have root access?
  * This is non-negotiable for purposes of a POV.
*Does the server have access to the internet and is it configured properly?
  * If not, download and install all packages manually.  Refer to offline install doc 

Managed Nodes

* Do they have root access?
  * If not, can whomever has root perform the bootstrap?
* Does the node have access to the internet?
  * If not, refer to the offline install doc


