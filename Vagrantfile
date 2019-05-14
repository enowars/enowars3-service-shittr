Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.network "private_network", ip: "fd00:1337:2::1337"
  config.vm.network "forwarded_port", guest: 31337, host: 31337
end
