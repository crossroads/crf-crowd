#
## Cookbook Name:: crf-crowd
## Recipe:: default
##
## Copyright 2015 Crossroads Foundation
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

override['apache']['default_site_enabled'] = false

default['crowd']['version']                      = '2.3.4'
default['crowd']['install_path']                 = '/opt/crowd'
default['crowd']['shared_path']                  = '/var/crowd'
default['crowd']['run_user']                     = 'crowd'
default['crowd']['log_dir']                      = '/var/log/crowd'
default['crowd']['pid_dir']                      = "#{node['crowd']['install_path']}/current/work"
default['crowd']['create_database']              = false
default['crowd']['database_name']                = 'crowd'
default['crowd']['database_user']                = 'crowd'
default['crowd']['database_password']            = secure_password
default['crowd']['database_host']                = '127.0.0.1'
default['crowd']['database_port']                = node['postgresql']['config']['port']
default['crowd']['database_superuser']           = 'postgres'
default['crowd']['database_superuser_password']  = node['postgresql']['password']['postgres']
default['crowd']['bind_tomcat_port']             = '8000'
default['crowd']['bind_http_port']               = '8080'
default['crowd']['bind_ajp_port']                = '8009'
default['crowd']['context_path']                 = '/'
default['crowd']['hostname']                     = 'crowd'
default['crowd']['domainname']                   = "#{node['crowd']['hostname']}.#{node['domain']}"
default['crowd']['bind_address']                 = '_default_'
default['crowd']['certificate']['data_bag']      = nil
default['crowd']['certificate']['data_bag_type'] = 'unencrypted'
default['crowd']['certificate']['search_id']     = 'cups'
default['crowd']['certificate']['cert_file']     = "#{node['fqdn']}.pem"
default['crowd']['certificate']['key_file']      = "#{node['fqdn']}.key"
default['crowd']['certificate']['chain_file']    = "#{node['hostname']}-bundle.crt"

