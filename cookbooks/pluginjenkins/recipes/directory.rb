%w[ /root/.jenkins /root/.jenkins/plugins ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  end
end
