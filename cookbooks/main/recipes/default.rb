#
# Basic server config: basic users, packages, etc.
#

### Packages
# Just base packages required by the whole system here, please. Dependencies
# for other recipes should live int hose recipes.

# Be sure to update apt-get first
bash "Update apt-get" do
  code "apt-get update"
end

node[:base_packages].each do |pkg|
  package pkg do
    action :upgrade
    retries 3
  end
end

### Users/groups

# Does the following setup for each user defined in node.json:
#   - creates a group and user paid with a matching uid/guid
#   - creates the home directory
#   - keys the user using a key from the config.
#
# Then creates a group for each group defined in the JSON.


if node.attribute?("all_servers")
  template "/etc/hosts" do
    source "hosts"
    mode 644
    variables :all_servers => node[:all_servers] || {}
  end
end

node[:users].each_pair do |username, info|
  group username do
    # print "USER: " + username + "group: " + info.inspect
    gid info[:id]
  end

  user username do
    comment info[:full_name]
    uid info[:id]
    gid info[:id]
    shell info[:disabled] ? "/sbin/nologin" : "/bin/bash"
    supports :manage_home => true
    home "/home/#{username}"
    password info[:password] if info[:password]
  end

  directory "/home/#{username}/.ssh" do
    owner username
    group username
    mode 0700
  end

  file "/home/#{username}/.ssh/authorized_keys" do
    owner username
    group username
    mode 0600
    content info[:key]
  end
end

node[:groups].each_pair do |name, info|
  group name do
    gid info[:gid]
    members info[:members]
  end
end




