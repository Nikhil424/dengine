require 'serverspec'

set :backend, :exec

describe 'Splunk Forwarder' do
  describe file('/opt/splunk/etc/system/local/distsearch.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should include 'servers = 192.168.88.88:8089,192.168.88.89:8089' }
  end

  describe file('/opt/splunk/etc/system/local/outputs.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should include 'server = 192.168.88.88:9997,192.168.88.89:9997' }
  end

  describe file('/opt/splunk/etc/system/local/props.conf') do
    it { should exist }
    it { should be_file }
  end
end
