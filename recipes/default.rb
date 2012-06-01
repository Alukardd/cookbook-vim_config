#
# Cookbook Name:: vim_config
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bundle_dir = node[:vim_config][:bundle_dir]
owner = node[:vim_config][:owner]
group = node[:vim_config][:owner_group]

directory bundle_dir do
  owner owner
  group group
  mode "0755"
  action :create
end

case node[:vim_config][:plugin_manager]
when :unbundle
  git "#{ bundle_dir }/vim-unbundle" do
    repository "git://github.com/sunaku/vim-unbundle.git"
    reference "master"
  end
else
  # use pathogen
  git "#{ bundle_dir }/vim-pathogen" do
    repository "git://github.com/tpope/vim-pathogen.git"
    reference "master"
  end
end

case node[:vim_config][:config_file_mode]
when :template
  template "#{ node[:vim_config][:installation_dir] }/#{ node[:vim_config][:config_file_name] }" do
    source "vimrc.local.erb"
    owner owner
    group group
    mode "0644"
  end
when :remote_file
  remote_file "#{ node[:vim_config][:installation_dir] }/#{ node[:vim_config][:config_file_name] }" do
    source node[:vim_config][:remote_config_url]
    backup false
    owner owner
    group group
    mode "0644"
  end
when :concatenate, :delegate
  directory "#{ node[:vim_config][:installation_dir] }/config.d" do
    owner owner
    group group
    mode "0755"
    action :create
  end

  # download all the config files
  node[:vim_config][:config_files].each_with_index do |config_file, index|
    remote_file "#{ index }-#{ config_file.split("/").last }" do
      source config_file
      backup false
      owner owner
      group group
      mode "0644"
    end
  end

  # write the config file itself
  if node[:vim_config][:config_file_mode] == :delegate
    cookbook_file "#{ bundle_dir }/#{ node[:vim_config][:config_file_name] }" do
      source "vimrc.local.delegated"
      owner owner
      group group
      mode "0644"
    end
  elsif node[:vim_config][:config_file_mode] == :concatenate
    config_file_content = "\"this is my config file"

    file "#{ bundle_dir }/#{ node[:vim_config][:config_file_name] }" do
      backup false
      owner owner
      group group
      mode "0644"
      content config_file_content
    end
  end
else
  log "No config file mode set, not managing config file"
end

node[:vim_config][:bundles][:git].each do |bundle|
  vim_config_git bundle do
    action :create
  end
end

node[:vim_config][:bundles][:vim].each do |name, version|
  vim_config_vim name do
    version version
    action :create
  end
end