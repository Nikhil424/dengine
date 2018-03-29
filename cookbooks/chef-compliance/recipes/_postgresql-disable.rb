include_recipe 'enterprise::runit'

runit_service 'postgresql' do
  action :disable
end
