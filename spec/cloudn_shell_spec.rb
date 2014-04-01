require "open3"
require "termcolor"
require_relative "../lib/cloudn_cli/shell"
require_relative "spec_helper"

include Cloudn

describe User do
  subject { User.new("name", api_key: "foo", secret_key: "bar", url: "url") }

  its(:name) do
    should == "name"
    should be_frozen
  end

  its(:api_key) do
    should == "foo"
    should be_frozen
  end

  its(:secret_key) do
    should == "bar"
    should be_frozen
  end

  its(:url) do
    should == "url"
    should be_frozen
  end
end

describe Shell do
  include ShellHelpers

  let(:script) { "bin/cloudn_cli" }

  context "command not exist" do
    subject { capture_err("foo") }
    it { should include alert("Exception OpenURI::HTTPError: status: 432  desc: The given command does not exist") }
  end

  context "show current format" do
    subject { capture_out("format") }
    it { should == ("> format\n> " + info("Current format is: JSON")) }
  end
  
  context "show current config" do
    let(:config_file_path) do
      dir = File.dirname(__FILE__)
      File.expand_path("../config.yml", dir)
    end
    
    let(:config) { YAML.load_file(config_file_path) }
    
    let(:config_pp_highlighted) do 
      pretty_printed = PP.pp(config, "")
      highlighted    = CodeRay.scan(pretty_printed, :ruby).term
      highlighted.chomp!
      return highlighted
    end

    subject do
      output = capture_out("config")
      output.gsub!(/^> config\n> /, "") # remove echo
      return output
    end
    
    it { should === config_pp_highlighted }
  end
  
  context "show listZones" do
    subject do
      output = capture_out("listZones")
      output.gsub!(/^> listZones\n> /, "") # remove echo
      return output
    end

    it "should be parsed as a JSON" do
      decolorized = decolorize(subject)
      expect { JSON.parse(decolorized) }.to_not raise_error
    end
  end
end
