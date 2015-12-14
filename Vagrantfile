VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/debian-7.9"

  # IP
  config.vm.network "private_network", ip: "192.168.50.20"

  # Shared folder
  config.vm.synced_folder ".", "/vagrant",
    :nfs => true,
    :mount_options => ['actimeo=2']

  # Timeout if box hangs
  config.vm.boot_timeout = 30

  # Hostname(s)
  config.vm.hostname = "odaa.vm"

  # What to install
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.raw_arguments = Shellwords.shellsplit(ENV['ANSIBLE_ARGS']) if ENV['ANSIBLE_ARGS']
  end

  # SSH
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
end
