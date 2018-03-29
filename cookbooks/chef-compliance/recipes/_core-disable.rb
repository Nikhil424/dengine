include_recipe 'enterprise::runit'

runit_service 'core' do
  action :disable
end
