# Cloudn CLI
[![Gem Version](https://badge.fury.io/rb/cloudn_cli.svg)](http://badge.fury.io/rb/cloudn_cli)

Cloudn CLI is command line tool for calling CloudStack API easily.

You can use this for your environment, or for commercial services such as Cloudn which is provided by NTT Communications.

Also, you can refer the list of all the APIs with following URL.

http://cloudstack.apache.org/docs/api/

## Installation
This step will be shown how to use Cloudn CLI.

We can roughly divide into two steps , one is the preparing part for executing the Ruby because Cloudn CLI is made by Ruby, and another one is environment settings for local.

## Setup the Ruby

At first, rbenv should be installed, which is tool for version administration of Ruby.
If you haven't installed git, please install that before this step.

1.Copy the rbenv from github

	$ git clone git://github.com/sstephenson/rbenv.git .rbenv 

2.Register the environment variables

	$ echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bash_profile
    $ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
	$ source ~/.bash_profile

3.Install some necessary packages
   
    $ git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    $ yum install readline libtool openssl openssl-devel

4.Installing the Ruby by using rbenv

    $ rbenv install 2.0.0-p451
    $ rbenv global 2.0.0-p451
    $ ruby --version

## Setup the Cloudn CLI
In this step, cloning Cloudn CLI and follow some necessary steps to execute

1.Clone the Cloudn CLI to your machine

	$ git clone https://github.com/nttcom/cloudn-cli.git

2.Install some necessary packages
    
    $ gem install bundler rb-readline
    $ rbenv rehash 
    $ bundle
    
3.Register the environment variables

    $ echo 'export PATH=$PATH:/<Your directory>/bin' >> ~/.bash_profile source ~/.bash_profile

4.Describe your settings which are api key, secret key, end endpoint of API into config.yml

	$ vi config.yml
	
5.Execute Cloudn CLI, and you can call any api refering the list of APIs

	$ cloudn_cli
	> listUsers

## Commands
Cloudn CLI has some original commands as follows

1.Refer the commands you can execute

    > help

2.Terminate the Cloudn CLI

	> exit

3.Display the current settings

	> config

4.Display the description of APIs

	> doc <name of APIs>

5.Change the format of return value

	> format <xml | json>

6.Choose the return value attribute

	> raw true | false

7.Choose the accounts which you want

	> user <name of account>

8.Display all the accounts in your config.yml

	> users

9.To be implemented

	> eval

## Contributing

1.Fork it

2.Create your feature branch (`git checkout -b my-new-feature`)

3.Commit your changes (`git commit -am 'Add some feature'`)

4.Push to the branch (`git push origin my-new-feature`)

5.Create new Pull Request
