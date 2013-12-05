## Cloudn CLI

Shell for CloudStack API

## Installation

## Setup the Ruby

1.Install Ruby for your machine by using "rbenv"

    $ git clone git://github.com/sstephenson/rbenv.git .rbenv 
    $ echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bash_profile
    $ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    $ source ~/.bash_profile
    $ git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    $ yum install readline libtool openssl openssl-devel
    $ rbenv install 2.0.0-p247
    $ rbenv global 2.0.0-p247

2.Clone the Cloudn CLI to your machine
    
    $ git clone https://github.com/nttcom/cloudn-cli.git

## Setup the Cloudn CLI
    
    $ gem install bundler rb-readline
    $ rbenv rehash 
    $ bundle install --path=vender/bundle
    $ echo 'export PATH=$PATH:/<Your directory>/bin' >> ~/.bash_profile source ~/.bash_profile
      
## Usage

1.Please set your configuration to config.yml

    $ vi config.yml

2.Then you can execute Cloudn CLI

    $ cloudstack_shell.rb

## Commands

1.Refer the commands you can execute

    > help

2.Switch the account of CloudStack

    > user <account name you set>
    
3.Execute the Cloudn / CloudStack API

    ex.
    > listUsers
    
    Tab completion can be used for API commands and parameters

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
