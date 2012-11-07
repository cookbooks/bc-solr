#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "java"
package "daemonize" if ["redhat", "centos", "suse"].include?(node[:platform])

template "/etc/init.d/solr" do
  source "solr-init.erb"
  owner "root"
  group "root"
  mode "0755"
end

java_ark "solr" do
  url node[:solr][:download_url]
  checksum  node[:solr][:download_checksum]
  app_home node[:solr][:home_dir]
  # bin_cmds ["java", "javac"]
  action :install
end

user "apache" do
  my_gid = (platform?("debian", "ubuntu") ? "nogroup" : "nobody")
  comment "Apache Runner"
  gid my_gid
  home node[:solr][:home_dir]
  shell "/bin/false"
end

directory node[:solr][:log_dir] do
  owner "apache"
  group "betterplace"
  mode "0775"
  action :create
end

directory File.join(node[:solr][:home_dir], node[:solr][:app_name], 'solr', 'data') do
  owner "apache"
  group "betterplace"
  mode "0775"
  action :create
end

# Install default templates
%w(elevate.xml schema.xml solrconfig.xml spellings.txt stopwords.txt synonyms.txt).each do |conf_template|
  template File.join(node[:solr][:home_dir], node[:solr][:app_name], 'solr', 'conf', conf_template) do
    source conf_template
    owner 'root'
    group 'root'
    mode '0644'
  end
end

service "solr" do
  action [:start]
  supports :start => true, :stop => true
end

