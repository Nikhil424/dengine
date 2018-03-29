def find_php_servers 

  slave_nodes = search(:node, "role:jfrog")
  slave_nodes.each do |node|
    value = node["cloud_v2"]["public_ipv4"]
  end
  ipaddress = value
end
