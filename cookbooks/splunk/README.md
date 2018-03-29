Description
===========

This Chef cookbook provides recipes for installing Splunk Server, Splunk Forwarders, and a few sample Splunk Apps (DeploymentMonitor, PDF Server, *nix) in Amazon EC2.  It also includes a provider for installing other Splunk Apps.

Changes
=======
* v0.2.3 - Bugfixes
* v0.2.2 - Forwarding/receiving revamp
  - Created separate recipes to enable forwarding/receiving.  Supports the following configurations:
    - Standard non-ssl forwarding
    - SSL forwarding using built-in self-signed certs
    - SSL forwarding using custom certs.
      - This implementation expects the user to populate custom certs via their own recipes.
  - Refer to [Splunk Documentation](http://docs.splunk.com/Documentation/Splunk/latest/Security/Aboutsecuringdatafromforwarders) for details on the various implementations.
  - NOTE:  Some attributes have changed!  Please review the below before upgrading from a previous version.
  - The following attributes are no longer used:
    - `node['splunk']['ssl_forwarding']`
      - replaced by `node['splunk']['forwarding']['ssl']['enable']`
    - `node['splunk']['ssl_forwarding_cacert']`
      - replaced by `node['splunk']['forwarding']['ssl']['cacert']`
      - This attribute is now simply a path to the custom cert on the node.  It is assumed that cookbook consumers have populated the cert themselves.
    - `node['splunk']['ssl_forwarding_servercert']`
      - replaced by `node['splunk']['forwarding']['ssl']['servercert']`
      - This attribute is now simply a path to the custom cert on the node.  It is assumed that cookbook consumers have populated the cert themselves.
    - `node['splunk']['ssl_forwarding_pass']`
      - Replaced by `node['splunk']['forwarding']['ssl']['password']`
    - `node['splunk']['receiver_port']`
      - Replaced by  `node['splunk']['forwarding']['port']`
  - New attributes: (See attributes/README.md for details)
    - `node['splunk']['forwarding']['compressed']`
    - `node['splunk']['forwarding']['indexers']`
    - `node['splunk']['forwarding']['port']`
    - `node['splunk']['forwarding']['ssl']['enable']`
    - `node['splunk']['forwarding']['ssl']['cacert']`
    - `node['splunk']['forwarding']['ssl']['servercert']`
    - `node['splunk']['forwarding']['ssl']['password']`
    - `node['splunk']['forwarding']['ssl']['requireClientCert']`
    - `node['splunk']['forwarding']['ssl']['sslVerifyServerCert']`
* v0.2.1 - App Provider Cleanup
  - Wrote new providers for installing Splunk Apps.
    - Separate providers for direct install, and extraction to clustering deployment folders.
  - Removed app binaries from Cookbook.
  - Removed recipes/code referencing old app install process.
  - Old provider remains for compatibility, but is deprecated.
* v0.2.0 -
  - Start of significant refactoring.
  - Extracted base installation steps into composable recipes.
    - download/install of splunk package (Handles both server and UF installs)
    - First Time Run steps
    - Updating default admin user credentials
  - Updated server/forwarder recipes to rely on the above, reducing code duplication.
  - Added the ability to run Splunk as a non-root user.  Default is still as root to avoid breaking existing installs.  This default may change in the future to reflect best practices for Splunk deployment.
  - Some attributes are changing / deprecated.  Details in the attributes/README.md
  - Cookbook now sets splunk 'servername', which affects how the install identifies itself outside of inputs. This corrects discrepancies between the two.  (Uncorrected, this would break attempts to correlate logs with REST responses)
* v0.1.1 - Added Test Kitchen integration, basic serverspecs, and updated default Splunk version.
* v0.1.0 - Added index configuration.  See attributes/indexes.rb
* v0.0.9 -
    - Added Distributed Searching.  This requires an Enterprise License with the CanBeRemoteMaster / DistSearch Feature Flags.  See the Distributed Search section for more details.
* v0.0.8 -
  - Added scripted authentication logic.  We use an external SSO system for logins.  Splunk's scripted authentication allows us to write custom scripts to interact with that SSO system to facilitate authentication.  See http://docs.splunk.com/Documentation/Splunk/5.0.1/Security/ConfigureSplunkToUsePAMOrRADIUSAuthentication for more information.
* v0.0.7 -
  - Broke up the attributes into separate files.  This will be needed as we add a lot of features to this cookbook
  - Redesigned how splunk starts -- fixed accept-license / answer-yes problems when starting splunk for the first time with version 5.
  - Added SSL Forwarding as an option.  See attributes/README.md under the forwarder.rb section.
    - With splunk having a unique secret per install, you may see a couple of splunk restarts while saves the encrypted passwords.  When you deploy a regular password (e.g., splunk), splunk will encrypt that regular password on service start and replace it in the config file.  On the next run, chef will read that encrypted password and save it for future runs, but may restart splunk because checksums will not match.
    - If you ever completely remove splunk and then install splunk, you will have to destroy two attributes on the nodes because the splunk.secret will be different.  We can solve this in the future releases.  The attributes are:
      node['splunk']['inputsSSLPass']
      node['splunk']['outputsSSLPass']
  - Removed default['splunk']['indexer_name'] in attributes/default.rb.
  - Got rid of the annoying output on the multiple "moving inputs file" for the forwarders.  It should now only do it once.
* v0.0.4 - Added a splunk app: Pulse for AWS Cloudwatch.  This app will pull back metrics from AWS Cloudwatch and provides sample dashboards to display the information.  Read the SETUP.txt located in the root directory of the app file for installation requirements.
* v0.0.3 - Changing version of Splunk to 4.3
* v0.0.2 - Revamp
* v0.0.1 - Initial Release

Current Bugs
============

* The name of the app file, minus the .tar.gz, needs to be the same name as the directory in which it extracts.  If it is named incorrectly, the app install will fail.

Requirements
============

## Platform:

* Ubuntu, Debian, RedHat, CentOS, Fedora

- The cookbook is currently setup to run being named "splunk".  If you rename the cookbook from the original name of "splunk", be sure to modify the following:
  * attributes/default.rb: `node['splunk']['cookbook_name']`
  * recipes/*-app.rb: splunk_app_install -> {NEW_NAME}_app_install (e.g., splunk_app_install)
- This cookbook has only been tested thoroughly with RHEL

Attributes
==========

See attributes/README.md for values.

Recipes
=======

server
------

Installs Splunk Server

forwarder
---------

Installs Splunk Forwarder


Usage
=====

## Forwarder Install:

This will install the Splunk Forwarder and shows an example of an attribute override to move a specific splunk `inputs.conf` file for this server.

```ruby
recipe[splunk::forwarder]
```

This will tell the forwarder to look for a `splunk_chef_server.inputs.conf.erb` file located in `templates/default/forwarder/FORWARDER_CONFIG_FOLDER`

```ruby
override_attributes(
  "splunk" => {
      "forwarder_config_folder" => "prod",
      "forwarder_role" => "splunk_chef_server"
  }
)
```

## Server Install:

```ruby
recipe[splunk::server]
```

To cause the Web interface, SplunkWeb, to be started, assign to the node the role designated in its `node['splunk']['server_role']` attribute ("splunk-server" by default).  It will be available on port `node['splunk']['web_server_port']`.  See [attributes/README.md](attributes/README.md) under the "default" section for more options, including SSL support and the default administrator password.

This will tell the splunk server to use the dynamic config files located in `templates/default/server/SERVER_CONFIG_FOLDER`:

```ruby
override_attributes(
  "splunk" => {
    "server_config_folder" => "prod"
  }
)
```

## Deployment Monitor App Install:

```ruby
recipe[splunk::deploy-mon-app]
```

Resources and Providers
=======================

splunk_app
----------
A default provider to install/upgrade/remove Splunk App bundles.

*Actions:*
* `:install` - Downloads the app bundle from the specified remote location and installs it.  If already installed, it will upgrade if the installed version does not match the specified version.  This is done via Splunk CLI interface, and is non-destructive of any local config files that may be in place.
* `:remove` - Removes the specified app bundle if installed.

*Attribute Parameters:*
* `:name` - The name of the app.  This must match what Splunk considers the app name to be, typically it's root folder name.  (Required)
* `:version` - The version of the app being installed.  This can be verified via `default/app.conf` in the app bundle if unknown.  (Required)
* `:remote_file` - The remote location of the app bundle file.  (Required)
* `:checksum` - Checksum of the app bundle file.  See the [remote_file resource](https://docs.chef.io/resource_remote_file.html) for details on `checksum` (Optional)

*Usage:*
This will install the Splunk Dashboard Examples app, and then notify the Splunk service to restart.  (This assumes 'artifact_repo' is a URL)

```ruby
splunk_app 'simple_xml_examples' do
  version '3.0'
  remote_file "#{artifact_repo}/splunk-6x-dashboard-examples_30.tgz"
  checksum 'ecf65fbde38befa66f2a88aa3d02903524cbdc57c40e0d439e5e4b3c7580c877'
  action :install
  notifies :restart, 'service[splunk]', :delayed
end
```

splunk_shc_app
----------
A default provider to install/upgrade/remove Splunk App bundles for distribution by a Search Head Cluster Deployer.

*Actions:*
* `:install` - Downloads the app bundle from the specified remote location extracts it to `$SPLUNK_HOME/etc/shcluster/apps`.  If already installed, it will upgrade if the installed version does not match the specified version.
* `:remove` - Removes the specified app bundle if installed.

*Attribute Parameters:*
* `:name` - The name of the app.  This must match what Splunk considers the app name to be, typically it's root folder name.  (Required)
* `:version` - The version of the app being installed.  This can be verified via `default/app.conf` in the app bundle if unknown.  (Required)
* `:remote_file` - The remote location of the app bundle file.  (Required)
* `:checksum` - Checksum of the app bundle file.  See the [remote_file resource](https://docs.chef.io/resource_remote_file.html) for details on `checksum` (Optional)

*Usage:*
This will install the Splunk Dashboard Examples app.  (This assumes 'artifact_repo' is a URL)

```ruby
splunk_shc_app 'simple_xml_examples' do
  version '3.0'
  remote_file "#{artifact_repo}/splunk-6x-dashboard-examples_30.tgz"
  checksum 'ecf65fbde38befa66f2a88aa3d02903524cbdc57c40e0d439e5e4b3c7580c877'
  action :install
end
```

splunk_idx_app
----------
A default provider to install/upgrade/remove Splunk App bundles for distribution by a Indexer Cluster Master.

*Actions:*
* `:install` - Downloads the app bundle from the specified remote location extracts it to `$SPLUNK_HOME/etc/master-apps`.  If already installed, it will upgrade if the installed version does not match the specified version.
* `:remove` - Removes the specified app bundle if installed.

*Attribute Parameters:*
* `:name` - The name of the app.  This must match what Splunk considers the app name to be, typically it's root folder name.  (Required)
* `:version` - The version of the app being installed.  This can be verified via `default/app.conf` in the app bundle if unknown.  (Required)
* `:remote_file` - The remote location of the app bundle file.  (Required)
* `:checksum` - Checksum of the app bundle file.  See the [remote_file resource](https://docs.chef.io/resource_remote_file.html) for details on `checksum` (Optional)

*Usage:*
This will install the Splunk Dashboard Examples app.  (This assumes 'artifact_repo' is a URL)

```ruby
splunk_idx_app 'simple_xml_examples' do
  version '3.0'
  remote_file "#{artifact_repo}/splunk-6x-dashboard-examples_30.tgz"
  checksum 'ecf65fbde38befa66f2a88aa3d02903524cbdc57c40e0d439e5e4b3c7580c877'
  action :install
end
```

DEPRECATED
----------
`app_install.rb`

A default provider to install Splunk Apps.  This will install any required dependencies, install or upgrade the application, and move any local templates that are required.

Actions:

* `create_if_missing` - Creates and installs the app if the specific version number specified is not installed.

Attribute Parameters:

* `app_file` - The file that needs to be extracted and installed.  (required)
* `app_version` - The version of the app.  (required)
* `required_dependencies` - An array of required package dependencies.  (optional)
* `local_templates` - An array of local templates in .erb format to move over to the applications local config directory.  These files are stored in templates/apps/#{local_templates_directory}.
* `local_templates_directory` - The directory in which the local templates are stored.  (required if defining local_templates) - (templates/default/apps/NAME)
* `remove_dir_on_upgrade` - Remove the app directory before extracting the new app.  (required)

Usage:

This will install or upgrade the *nix app:

```ruby
splunk_app_install "Installing #{node[:splunk][:unix_app_file]} -- Version: #{node[:splunk][:unix_app_version]}" do
  action                  [:create_if_missing]
  app_file                "#{node[:splunk][:unix_app_file]}"
  app_version             "#{node[:splunk][:unix_app_version]}"
  local_templates_directory "unix-app"
  local_templates         ["app.conf.erb","inputs.conf.erb"]
  remove_dir_on_upgrade   "true"
end
```

Distributed Search
==================

** Requires a License with CanBeRemoteMaster / DistSearch Feature Flags.  Trial licenses do not appear CanBeRemoteMaster.

Distributed Search (1-n Search Heads <-> 1-n Search Indexers) setup is not complex, but does require a few chef runs.  We run chef-client as a service every XX minutes to keep the search nodes and indexers up to date.  When we add new indexers, within XX minutes the search peers will be updated on all the search heads.

This implementation will be a 1-n Search Head/Indexer setup.  Future versions will include an implementation to allow n-n with shared bundles.

## Setup:

1. Override `node['splunk']['distributed_search']` to true
2. Override `node['splunk']['distributed_search_master']` to the local IP of the master license server.
3. Set the search head role to the value of `node['splunk']['server_role']`
4. Set the search indexer role to the value of `node['splunk']['indexer_role']`
5. Run Chef on the Search Head -- This will save the instance's `ServerName` and `trusted.pem` contents as an attributeto the chef server.
6. Run Chef on the Search Indexer -- This will deploy the search heads `trusted.pem` to the local indexer (`node['splunk']['server_home']/etc/auth/distServerKeys/ServerName`) and create a `distsearch.conf`.
7. Run Chef on the Search Head -- This will modify the `distsearch.conf` to point to the indexer.

A lot of steps?  Perhaps, but if it's running as a service you can technically do steps 1-4 and let the service runs do 5-7.  It just may take a little longer depending on how often chef runs.

License and Author
==================

Author:: Andrew Painter (<andrew.painter@bestbuy.com>)
Author:: Bryan Brandau (<bryan.brandau@bestbuy.com>)
Author:: Aaron Peterson (<aaron@opscode.com>)

Copyright 2011-2012, BBY Solutions, Inc.
Copyright 2011-2012, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
