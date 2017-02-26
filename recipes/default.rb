#
# Cookbook:: sage-cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# SAGE2 deps
# NodeJS :

include_recipe 'nodejs'

pkgs = %w(ghostscript imagemagick libcap2-bin libnss3-tools
          libimage-exiftool-perl git-core)

case node['platform']
when /debian/
  pkgs << 'chromium-browser-l10n'
when /raspbian/
else
  pkgs << 'chromium-browser'
end
package pkgs

repo = node['sage2']['repository']       # https://bitbucket.org/sage2/sage2.git
branch = node['sage2']['branch']         # master
install_path = node['sage2']['path']     # /opt/sage2/
username = node['sage2']['user']         # sage
groupname = node['sage2']['group']       # sage
make_user = node['sage2']['make_user']   # false
# TODO: FIXME temp override for dev purposes
username = 'sage'
groupname = 'sage'
make_user = true

if make_user
  group groupname do
    action [:create]
  end
  user username do
    comment 'SAGE2 User'
    group groupname
    home install_path
    shell '/bin/bash'
    action [:create]
  end
end

directory install_path do
  user username
  group groupname
  action [:create]
end

git 'sage2' do
  repository          node['sage2']['repository']
  depth               1
  destination         install_path
  group               groupname      # node['sage2']['group'] # sage
  user                username       # node['sage2']['user'] # sage
  action              [:checkout] # defaults to :sync if not specified

  if node['sage2']['branch'] != 'master'
    checkout_branch   node['sage2']['branch']
    enable_checkout   false
  end
end

bash 'sage2-keys' do
  user username
  group groupname
  cwd File.join(install_path, 'keys')
  environment 'HOME' => install_path
  code <<-EOH
  ./GO-linux
  EOH
  not_if { ::File.exist?(File.join(install_path, '.pki')) }
end

bash 'sage2-npm_install' do
  user username
  group groupname
  cwd install_path
  environment 'HOME' => install_path
  code <<-EOH
  /usr/bin/npm install
  EOH
  not_if { ::File.exist?(File.join(install_path, '.npm')) }
end

# cd install_path/keys
# ./GO-linux
# cd ..
# [path to node]/bin/npm install
# start the server
# [path to node]/bin/node server.js -l

# add sage2 as a systemd service
# https://bitbucket.org/sage2/sage2/wiki/systemd%20startup

# start the service
