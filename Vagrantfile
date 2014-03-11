# Vagrant 1.5.0 <http://www.vagrantup.com/downloads.html>
# VirtualBox 4.3.8 <https://www.virtualbox.org/wiki/Downloads>

Vagrant.require_version '>= 1.5.0'

Vagrant.configure('2') do |config|
  config.vm.box = 'chef/ubuntu-13.10'

  config.ssh.forward_agent = true

  config.vm.provision :shell, inline: <<-'SH'
    set -e -x
    update-locale LC_ALL=en_US.UTF-8
    apt-get update
    apt-get -y install libffi-dev make
    if ! ruby -v | grep -F -q 2.1.1p76; then
      test -f ruby-2.1.1.tar.bz2 ||
        wget -q cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.bz2
      test -f ruby-2.1.1.tar ||
        bunzip2 -k -q ruby-2.1.1.tar.bz2
      test -d ruby-2.1.1 ||
        tar -x -f ruby-2.1.1.tar
      cd ruby-2.1.1
      ./configure --disable-install-doc
      make
      make install
      cd ..
    fi
    gem --version | grep -F -q 2.2.2 ||
      gem update --no-document --system 2.2.2
  SH

  config.vm.provision :shell, inline: <<-'SH', privileged: false
    set -e -x
    echo '{ gem: --no-document, install: --user-install }' > .gemrc
    echo 'PATH="$(ruby -e puts\(Gem.user_dir\))/bin:$PATH"' > .bash_profile
    source .bash_profile
    gem install bundler
    cd /vagrant
    bundle install
  SH
end
