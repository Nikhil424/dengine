#.....This recipe is to set node attributes incase if node is added to existing setup.......

class Chef::Recipe
   include AttributeNode
end

versions = get_build_verion

node.set['dengine']['artifact']['version']       = "#{versions.first}"
node.set['dengine']['artifact']['roll_version']  = "#{versions.last}"
