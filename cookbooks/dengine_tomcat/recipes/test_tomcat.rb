%w[ /root/nikhil].each do |path|
  directory path do
  owner 'ubuntu'
  group 'ubuntu'
  mode  '0777'
  end
end
