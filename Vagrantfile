# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # config.vm.box = "puppetlabs/debian-7.8-64-nocm"
  config.vm.box = "ubuntu/trusty64"
  
  # config.vm.synced_folder ENV['STACK_BUILD_DIR'], "/vagrant-build", type: "rsync", rsync__verbose: true, rsync__exclude: [".stack-work/", "_release/", ".cabal-sandbox/", "cabal.sandbox.config", "dist/", ".#*#", "*.vdi", "*.vmdk", "*.raw", ".DS_Store"], rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  # config.vm.synced_folder "../../..", "/vagrant", type: "rsync", rsync__verbose: true, rsync__exclude: [".stack-work/", "_release/", ".cabal-sandbox/", "cabal.sandbox.config", "dist/", ".#*#", "*.vdi", "*.vmdk", "*.raw", ".DS_Store"], rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  config.vm.synced_folder ".", '/home/vagrant/whph-website', :owner => "vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"
  end
  
  config.ssh.forward_agent = true

  config.vm.hostname = "whph-stack"
  
  config.vm.provision "shell", inline: <<-SHELL
    set -xe
    export PATH=/usr/local/bin:$PATH
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y net-tools wget zlib1g-dev ruby-dev libgmp-dev lsb-release ca-certificates libtinfo-dev unzip
    if ! which stack; then
      wget -q -O get_stack.sh http://get.haskellstack.org/
      chmod +x get_stack.sh
      ./get_stack.sh
    fi
  SHELL
end
