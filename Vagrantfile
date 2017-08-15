# pges

Vagrant.configure(2) do |config|
  config.vm.hostname = "pges"
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64"

  config.vm.network :private_network, ip: "192.168.100.100"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "pges"
    vb.gui = false
    vb.memory = 512
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

end
