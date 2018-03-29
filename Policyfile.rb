# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name "test_policy"

# Where to find external cookbooks:
#default_source :supermarket
default_source:chef_repo, "/root/chef-repo/"

# run_list: chef-client will run these recipes in the order specified.
node[node.policy_group]['dengine']['artifact']['version']     = '0.0'
node[node.policy_group]['dengine']['artifact']['rollversion'] = '0.0'
node['dengine']['artifact']['name']        = 'gameoflife-web'
node['dengine']['artifact']['deployment']  = 'false'

run_list "dengine::default"

# Specify a custom source for a single cookbook:
# cookbook "example_cookbook", path: "../cookbooks/example_cookbook"
