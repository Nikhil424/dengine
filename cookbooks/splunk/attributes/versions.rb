##Set the Splunk Version to be used

# Consolidating version attributes
default['splunk']['download_root'] = 'http://download.splunk.com/releases'
default['splunk']['version']       = '6.3.1'
default['splunk']['build']         = 'f3e41e4b37b2'
# If downloading from a custom location, simply provide full URL
default['splunk']['remote_url']                   = nil

# Legacy Attributes (Deprecated)
#Server
default['splunk']['server_root']                  = "http://download.splunk.com/releases"
default['splunk']['server_version']               = "6.3.1"
default['splunk']['server_build']                 = "f3e41e4b37b2"

#Forwarder
default['splunk']['forwarder_root']               = "http://download.splunk.com/releases"
default['splunk']['forwarder_version']            = "6.3.1"
default['splunk']['forwarder_build']              = "f3e41e4b37b2"
