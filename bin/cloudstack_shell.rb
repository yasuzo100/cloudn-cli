#!/usr/bin/env ruby
require_relative "../lib/cloudstack_shell/shell"

source_dir = File.dirname(__FILE__)
CloudStack::Shell.new(File.expand_path("../config.yml", File.dirname(__FILE__)))
