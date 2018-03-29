#recipe for aritifactory

repository_startservice 'starting artifactory' do
  action :install
  not_if { File.exists?('/root/artifactory-oss-4.7.7/run/artifactory.pid') }
end
