require 'serverspec'

set :backend, :exec

describe 'Splunk Server' do
  describe process('splunkd') do
    its(:user) { should match 'splunk' }
  end

  describe file('/opt/splunk/etc/splunk-launch.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should include 'SPLUNK_HOME=/opt/splunk' }
    its(:content) { should include 'SPLUNK_OS_USER=splunk' }
  end
end
