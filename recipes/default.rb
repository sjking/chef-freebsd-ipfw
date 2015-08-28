
# Cookbook Name:: chef_freebsd_ipfw
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Steve King
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

firewall_data_bag = Chef::DataBagItem.load('firewall', node['hostname'])
fw_rules = firewall_data_bag["rules"]

# Enable the firewall in rc.conf
execute "enable-firewall" do
   user "root"
   command "echo 'firewall_enable=\"YES\"' >> /etc/rc.conf"
   not_if "grep 'firewall_enable=\"YES\"' /etc/rc.conf"
end

execute "enable-firewall-logging" do
  user "root"
  command "echo 'firewall_logging=\"YES\"' >> /etc/rc.conf"
  not_if "grep 'firewall_logging=\"YES\"' /etc/rc.conf"
end

execute "set-firewall-config-file" do
  user "root"
  command "echo 'firewall_script=\"/etc/ipfw.rules\"' >> /etc/rc.conf"
  not_if "grep 'firewall_script=\"/etc/ipfw.rules\"' /etc/rc.conf"
end

execute "set-logging-limits" do
  user "root"
  command "echo 'net.inet.ip.fw.verbose_limit=5' >> /etc/sysctl.conf"
  not_if "grep 'net.inet.ip.fw.verbose_limit=5' /etc/sysctl.conf"
end

# create the firewall config file
cookbook_file "/etc/ipfw.rules" do
  source fw_rules
  owner "root"
  group "wheel"
  mode "0644"
  action :create
  notifies :run, "execute[reload-firewall-config]", :delayed
end

script "start-firewall" do
  interpreter "sh"
  user "root"
  code <<-EOF
    service ipfw start 2> /dev/null
    [ "$?" -ne 0 ] && service ipfw onestart
    sysctl net.inet.ip.fw.verbose_limit=5
  EOF
  not_if "ipfw list"
end


execute "reload-firewall-config" do
  user "root"
  command "sh /etc/ipfw.rules"
  action :nothing
end
