require 'serverspec'

set :backend, :exec

describe 'Splunk Server' do
  describe user('splunk') do
    it { should exist }
    it { should belong_to_group 'splunk' }
    it { should have_uid 396 }
    it { should have_home_directory '/opt/splunk' }
    it { should have_login_shell '/bin/bash' }
  end

  describe group('splunk') do
    it { should exist }
    it { should have_gid 396 }
  end

  describe service('splunk') do
    it { should be_enabled }
    it { should be_running }
  end

  describe process('splunkd') do
    its(:user) { should match 'root' }
  end

  describe port(8000) do
    it { should be_listening }
  end

  describe file('/opt/splunk/etc/splunk-launch.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should include 'SPLUNK_HOME=/opt/splunk' }
    its(:content) { should include 'SPLUNK_OS_USER=root' }
  end

  describe file('/opt/splunk/etc/.setup_admin_pwd') do
    it { should exist }
  end

  describe file('/opt/splunk_setup_passwd') do
    it { should_not exist }
  end

  describe file('/opt/splunk/etc/splunk.version') do
    it { should exist }
    its(:content) { should include 'VERSION=6.3.1' }
    its(:content) { should include 'BUILD=f3e41e4b37b2' }
  end

  describe file('/opt/splunk/etc/system/local/server.conf') do
    its(:content) { should include 'serverName = splunk-server.local-splunk' }
  end
end
