%w[ /var/deploy/ /var/deploy/current /var/deploy/release].each do |path|
  directory path do
  owner 'ubuntu'
  group 'ubuntu'
  mode  '0777'
  end
end
