provides :hostname
resource_name :hostname

property :hostname, String, name_property: true
property :compile_time, [ true, false ], default: true
property :ipaddress, [ String, nil ], default: node["ipaddress"]
property :aliases, [ Array, nil ], default: nil
property :windows_reboot, [ true, false ], default: true

default_action :set

action_class do
  def append_replacing_matching_lines(path, regex, string)
    text = IO.read(path).split("\n")
    text.reject! { |s| s =~ regex }
    text += [ string ]
    file path do
      content text.join("\n") + "\n"
      owner "root"
      group node["root_group"]
      mode "0644"
      not_if { IO.read(path).split("\n").include?(string) }
    end
  end

  def docker_guest?
    node["virtualization"] && node["virtualization"]["systems"] &&
      node["virtualization"]["systems"]["docker"] && node["virtualization"]["systems"]["docker"] == "guest"
  end
end

action :set do
  ohai "reload hostname" do
    plugin "hostname"
    action :nothing
  end

  if node["platform_family"] != "windows"
    # set the hostname via /bin/hostname
    execute "set hostname to #{new_resource.hostname}" do
      command "/bin/hostname #{new_resource.hostname}"
      not_if { shell_out!("hostname").stdout.chomp == new_resource.hostname }
      notifies :reload, "ohai[reload hostname]"
    end

    # make sure node['fqdn'] resolves via /etc/hosts
    unless new_resource.ipaddress.nil?
      newline = "#{new_resource.ipaddress} #{new_resource.hostname}"
      newline << " #{new_resource.aliases.join(" ")}" if new_resource.aliases && !new_resource.aliases.empty?
      newline << " #{new_resource.hostname[/[^\.]*/]}"
      r = append_replacing_matching_lines("/etc/hosts", /^#{new_resource.ipaddress}\s+|\s+#{new_resource.hostname}\s+/, newline)
      r.atomic_update false if docker_guest?
      r.notifies :reload, "ohai[reload hostname]"
    end

    # setup the hostname to perist on a reboot
    case
    when ::File.exist?("/usr/sbin/scutil")
      # darwin
      execute "set HostName via scutil" do
        command "/usr/sbin/scutil --set HostName #{new_resource.hostname}"
        not_if { shell_out!("/usr/sbin/scutil --get HostName").stdout.chomp == new_resource.hostname }
        notifies :reload, "ohai[reload hostname]"
      end
      execute "set ComputerName via scutil" do
        command "/usr/sbin/scutil --set ComputerName  #{new_resource.hostname}"
        not_if { shell_out!("/usr/sbin/scutil --get ComputerName").stdout.chomp == new_resource.hostname }
        notifies :reload, "ohai[reload hostname]"
      end
      shortname = new_resource.hostname[/[^\.]*/]
      execute "set LocalHostName via scutil" do
        command "/usr/sbin/scutil --set LocalHostName #{shortname}"
        not_if { shell_out!("/usr/sbin/scutil --get LocalHostName").stdout.chomp == shortname }
        notifies :reload, "ohai[reload hostname]"
      end
    when node["os"] == "linux"
      case
      when ::File.exist?("/usr/bin/hostnamectl") && !docker_guest?
        # use hostnamectl whenever we find it on linux (as systemd takes over the world)
        # this must come before other methods like /etc/hostname and /etc/sysconfig/network
        execute "hostnamectl set-hostname #{new_resource.hostname}" do
          notifies :reload, "ohai[reload hostname]"
          not_if { shell_out!("hostnamectl status", { :returns => [0, 1] }).stdout =~ /Static hostname:\s+#{new_resource.hostname}/ }
        end
      when ::File.exist?("/etc/hostname")
        # debian family uses /etc/hostname
        # arch also uses /etc/hostname
        # the "platform: iox_xr, platform_family: wrlinux, os: linux" platform also hits this
        # the "platform: nexus, platform_family: wrlinux, os: linux" platform also hits this
        # this is also fallback for any linux systemd host in a docker container (where /usr/bin/hostnamectl will fail)
        file "/etc/hostname" do
          atomic_update false if docker_guest?
          content "#{new_resource.hostname}\n"
          owner "root"
          group node["root_group"]
          mode "0644"
        end
      when ::File.exist?("/etc/sysconfig/network")
        # older non-systemd RHEL/Fedora derived
        append_replacing_matching_lines("/etc/sysconfig/network", /^HOSTNAME\s*=/, "HOSTNAME=#{new_resource.hostname}")
      when ::File.exist?("/etc/HOSTNAME")
        # SuSE/OpenSUSE uses /etc/HOSTNAME
        file "/etc/HOSTNAME" do
          content "#{new_resource.hostname}\n"
          owner "root"
          group node["root_group"]
          mode "0644"
        end
      when ::File.exist?("/etc/conf.d/hostname")
        # Gentoo
        file "/etc/conf.d/hostname" do
          content "hostname=\"#{new_resource.hostname}\"\n"
          owner "root"
          group node["root_group"]
          mode "0644"
        end
      else
        # This is a failsafe for all other linux distributions where we set the hostname
        # via /etc/sysctl.conf on reboot.  This may get into a fight with other cookbooks
        # that manage sysctls on linux.
        append_replacing_matching_lines("/etc/sysctl.conf", /^\s+kernel\.hostname\s+=/, "kernel.hostname=#{new_resource.hostname}")
      end
    when ::File.exist?("/etc/rc.conf")
      # *BSD systems with /etc/rc.conf + /etc/myname
      append_replacing_matching_lines("/etc/rc.conf", /^\s+hostname\s+=/, "hostname=#{new_resource.hostname}")

      file "/etc/myname" do
        content "#{new_resource.hostname}\n"
        owner "root"
        group node["root_group"]
        mode "0644"
      end
    when ::File.exist?("/etc/nodename")
      # Solaris <= 5.10 systems prior to svccfg taking over this functionality (must come before svccfg handling)
      file "/etc/nodename" do
        content "#{new_resource.hostname}\n"
        owner "root"
        group node["root_group"]
        mode "0644"
      end
      # Solaris also has /etc/inet/hosts (copypasta alert)
      unless new_resource.ipaddress.nil?
        newline = "#{new_resource.ipaddress} #{new_resource.hostname}"
        newline << " #{new_resource.aliases.join(" ")}" if new_resource.aliases && !new_resource.aliases.empty?
        newline << " #{new_resource.hostname[/[^\.]*/]}"
        r = append_replacing_matching_lines("/etc/inet/hosts", /^#{new_resource.ipaddress}\s+|\s+#{new_resource.hostname}\s+/, newline)
        r.notifies :reload, "ohai[reload hostname]"
      end
    when ::File.exist?("/usr/sbin/svccfg")
      # Solaris >= 5.11 systems using svccfg (must come after /etc/nodename handling)
      execute "svccfg -s system/identity:node setprop config/nodename=\'#{new_resource.hostname}\'" do
        notifies :run, "execute[svcadm refresh]", :immediately
        notifies :run, "execute[svcadm restart]", :immediately
        not_if { shell_out!("svccfg -s system/identity:node listprop config/nodename").stdout.chomp =~ /config\/nodename\s+astring\s+#{new_resource.hostname}/ }
      end
      execute "svcadm refresh" do
        command "svcadm refresh system/identity:node"
        action :nothing
      end
      execute "svcadm restart" do
        command "svcadm restart system/identity:node"
        action :nothing
      end
    else
      raise "Do not know how to set hostname on os #{node["os"]}, platform #{node["platform"]},"\
        "platform_version #{node["platform_version"]}, platform_family #{node["platform_family"]}"
    end

  else # windows

    # suppress EC2 config service from setting our hostname
    ec2_config_xml = 'C:\Program Files\Amazon\Ec2ConfigService\Settings\config.xml'
    cookbook_file ec2_config_xml do
      source "config.xml"
      only_if { ::File.exist? ec2_config_xml }
    end

    # update via netdom
    powershell_script "set hostname" do
      code <<-EOH
        $sysInfo = Get-WmiObject -Class Win32_ComputerSystem
        $sysInfo.Rename("#{new_resource.hostname}")
      EOH
      not_if { Socket.gethostbyname(Socket.gethostname).first == new_resource.hostname }
    end

    # reboot because $windows
    reboot "setting hostname" do
      reason "chef setting hostname"
      action :request_reboot
      only_if { new_resource.windows_reboot }
    end
  end
end

# this resource forces itself to run at compile_time
def after_created
  if compile_time
    Array(action).each do |action|
      self.run_action(action)
    end
  end
end
