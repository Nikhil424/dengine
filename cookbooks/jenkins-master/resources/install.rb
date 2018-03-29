resource_name :gem_install

action :install do

gems = {
'fog-azure-rm'     =>  '0.3.2',
'fog-core'         =>  '1.43.0',
'fog-aws'          =>  '1.2.0',
'aws-sdk'          =>  '2.7.3',
'knife-ec2'        =>  '0.15.0',
'knife-rackspace'  =>  '1.0.3',
'knife-google'     =>  '3.1.1',
'foodcritic'       =>  '9.0.0',
#'knife-azure'      =>  '1.7.0',
}

gems.each_with_index do |(gem_name, gem_version), index|
  gem_package gem_name do
    version gem_version
  end
end

end
