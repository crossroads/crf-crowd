#
# Cookbook Name:: crf-crowd
# Recipe:: default
#
# Copyright 2015 Crossroads Foundation
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'java'
include_recipe 'java::purge_packages'
include_recipe 'postgresql'
include_recipe 'postgresql::yum_pgdg_postgresql'
include_recipe 'postgresql::server'
include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_proxy_ajp'
include_recipe 'apache2::mod_ssl'
include_recipe 'database::postgresql'

user node['crowd']['run_user'] do
  comment "User that Crowd runs under"
end

directory node['crowd']['install_path'] do
  recursive true
  owner node['crowd']['run_user']
end

directory node['crowd']['shared_path'] do
  recursive true
  owner node['crowd']['run_user']
end

# Create the Crowd database user.
postgresql_database_user node['crowd']['database_user'] do
  connection(
    :host      => node['crowd']['database_host'],
    :port      => node['crowd']['database_port'], 
    :username  => node['crowd']['database_superuser'],
    :password  => node['crowd']['database_superuser_password']
  )
  password node['crowd']['database_password']
  action   :create
  only_if { node['crowd']['create_database'] == true }
end

# Create the Crowd database.
postgresql_database node['crowd']['database_name'] do
  connection(
    :host      => node['crowd']['database_host'],
    :port      => node['crowd']['database_port'],
    :username  => node['crowd']['database_superuser'],
    :password  => node['crowd']['database_superuser_password']
  )
  owner  node['crowd']['database_user']
  action :create
  only_if { node['crowd']['create_database'] == true }
end

unless FileTest.exists?("#{node['crowd']['install_path']}/#{node['crowd']['version']}")

  remote_file 'crowd' do
    path "#{Chef::Config['file_cache_path']}/crowd.tar.gz"
    source "https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-#{node['crowd']['version']}.tar.gz" 
  end

  bash 'untar-crowd' do
    code "(cd #{Chef::Config['file_cache_path']}; tar zxvf #{Chef::Config['file_cache_path']}/crowd.tar.gz)"
  end

  bash 'install-crowd' do
    code "mv #{Chef::Config['file_cache_path']}/atlassian-crowd-#{node['crowd']['version']} #{node['crowd']['install_path']}/#{node['crowd']['version']}"
  end

  bash 'set-crowd-permissions' do
    code "chown -R #{node['crowd']['run_user']} #{node['crowd']['install_path']}/#{node['crowd']['version']} #{node['crowd']['shared_path']}"
  end

  bash 'cleanup-crowd' do
    code "rm -rf #{Chef::Config['file_cache_path']}/crowd.tar.gz"
  end

end

directory "#{node['crowd']['install_path']}/#{node['crowd']['version']}" do
  recursive true
  owner node['crowd']['run_user']
end

directory node['crowd']['log_dir'] do
  recursive true
  owner node['crowd']['run_user']
  action :create
end

directory node['crowd']['pid_dir'] do
  recursive true
  owner node['crowd']['run_user']
  action :create
end

directory "#{node['crowd']['install_path']}/current/logs" do
  action :delete
  not_if do File.symlink?("#{node['crowd']['install_path']}/current/logs") end
end

link "#{node['crowd']['install_path']}/current/logs" do
  to        node['crowd']['log_dir']
  link_type :symbolic
end

link "#{node['crowd']['install_path']}/current/lib/postgresql-jdbc.jar" do
  to "/usr/share/java/postgresql#{node['postgresql']['version'].split('.').join}-jdbc.jar"
  link_type :symbolic
end

firewall_rule 'crowd-ports' do
  protocol  :tcp
  port      [80, 443]
end

template '/usr/lib/systemd/system/crowd.service' do
  source   'crowd.service.erb'
end

service 'crowd' do
  supports :start => true, :stop => true, :restart => true
  action [ :enable, :start ]
end

template "#{node['crowd']['install_path']}/current/atlassian-crowd/WEB-INF/classes/crowd-application.properties" do
  source   'crowd-application.properties.erb'
  owner    node['crowd']['run_user']
  mode     '0640'
  notifies :reload, 'service[crowd]'
end

# Create the certificates.
certificate_manage 'crowd' do
  data_bag      node['crowd']['certificate']['data_bag']
  data_bag_type node['crowd']['certificate']['data_bag_type']
  search_id     node['crowd']['certificate']['search_id']
  cert_file     node['crowd']['certificate']['cert_file']
  key_file      node['crowd']['certificate']['key_file']
  chain_file    node['crowd']['certificate']['chain_file']
end

template "#{node['apache']['dir']}/sites-available/crowd.conf" do
  source 'apache2.conf.erb'
  owner  node['apache']['user']
  group  node['apache']['user']
  mode   '0640'
  backup false
  notifies :restart, 'service[crowd]'
end

template "#{node['crowd']['install_path']}/current/conf/server.xml" do
  source 'server.xml.erb'
  owner node['crowd']['run_user']
  mode   '0640'
  backup false
  notifies :restart, 'service[crowd]'
end

apache_site 'crowd' do
  enable true
end
