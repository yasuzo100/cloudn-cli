#!/usr/bin/env ruby
require_relative "../lib/cloudn_cli/shell"

source_dir = File.dirname(__FILE__)
Cloudn::Shell.new(File.expand_path("../config.yml", File.dirname(__FILE__)))
