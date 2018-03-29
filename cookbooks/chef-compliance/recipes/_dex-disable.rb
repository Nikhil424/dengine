include_recipe 'enterprise::runit'

%w{ dex-worker dex-overlord }.each do |svc|
  runit_service svc do
    action :disable
  end
end
