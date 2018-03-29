include_recipe 'enterprise::runit'

runit_service 'nginx' do
  action :disable
end
