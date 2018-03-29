require 'chef/knife'
require 'fileutils'
require 'artifactory'

module DeployArtifact

  include Artifactory::Resource

  def arti_deploy(app_name,art_version)

    download_path = '/var/deploy/tmp'
    
    if ensure_dir(download_path) == true

      arti_ip = get_arti_ip
      download_artifact(app_name,art_version,arti_ip,download_path)

    else

      Chef::Log.info("====================================")
      Chef::Log.info("The artifactory download path: '#{download_path}' is not created by chef, even though I'll download in required location")
      arti_ip = get_arti_ip
      Chef::Log.info("")
      Chef::Log.info("Artifact download in progress")
      Chef::Log.info(".")
      Chef::Log.info(".")
      download_artifact(app_name,art_version,arti_ip,download_path)
      Chef::Log.info("Artifact downloaded successfully")
      Chef::Log.info("====================================")
      Chef::Log.info("")

    end

  end

  def download_artifact(app_name,art_version,arti_ip,download_path)

    data_item = Chef::DataBagItem.new
    data_item.data_bag("dengine")
    data_value = Chef::DataBagItem.load("dengine","artifactory")
    data_value.raw_data['username']

    Artifactory.configure do |config|
    config.endpoint = "http://#{arti_ip}:8081/artifactory/"
    config.username = data_value.raw_data['username'].to_s
    config.password = data_value.raw_data['pasword'].to_s
    end

    artifact = Artifact.search(name: "#{app_name}-#{art_version}.war").first
    artifact.download(download_path)
    FileUtils.cp_r "#{download_path}/#{app_name}-#{art_version}.war", '/var/deploy/current'

  end

  def ensure_dir(download_path)

    if Dir.exists? "#{download_path}"
      return true
    else
      return false
    end

  end

  def get_arti_ip

    artifactory = search(:node, "role:jfrog")
    if artifactory.empty?
      arti_ip = '127.0.0.1'
    else
      arti_ip = artifactory.first["cloud_v2"]["public_ipv4"]
    end

    return arti_ip
  end

end
