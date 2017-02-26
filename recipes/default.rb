#
# Cookbook:: sage-cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# SAGE2 deps
# NodeJS :

if node['platform'] =~ /raspbian/
  #node.override['nodejs']['install_method'] = 'source'
  #include_recipe 'nodejs'

  # https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-armv7l.tar.xz
  # 95efb476886df15cc6586dd26ecc50834a768e347cf95e861461853cfb40fc78
  # tar xf node-v6.10.0-linux-armv7l.tar.xz -C /usr/local/
  # ln -s /usr/local/node-v6.10.0-linux-armv7l/bin/* /usr/local/bin
else
  include_recipe 'nodejs'
end

pkgs = %w(ghostscript imagemagick libcap2-bin libnss3-tools
          libimage-exiftool-perl git-core)

case node['platform']
when /debian/
#  pkgs << 'chromium-browser-l10n'
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
  npm install
  EOH
  only_if { File.exist?('/usr/local/bin/npm') || File.exist?('/usr/bin/npm') }
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
