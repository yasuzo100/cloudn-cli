require_relative "../lib/cloudstack_shell/client"

include CloudStack

describe Client do
  let(:config) do
    dir = File.dirname(__FILE__)
    config_file_path = File.expand_path("../config.yml", dir)
    config = YAML.load_file(config_file_path)
  end

  let(:user) { config[:users].values.first }

  shared_examples_for Client do
    its(:url) do
      should be_a URI::HTTP
      should be_frozen
    end
    
    it "protects its api_key and secret_key" do
      expect { subject.api_key }.to raise_error(NoMethodError)
      expect { subject.secret_key }.to raise_error(NoMethodError)
    end
    
    describe "#get" do
      subject { super().get(command: :listZones) }
      it { should be_a Hash }
      it { should_not be_empty }
    end
  end

  context "response type: XML" do
    subject do
      Client.new(
        url: config[:url],
        api_key: user[:api_key],
        secret_key: user[:secret_key]
      )
    end

    it_behaves_like Client

    describe "#get_row" do
      it "returns valid XML" do
        expect {
          Crack::XML.parse(subject.get_raw(command: :listZones))
        }.to_not raise_error
      end
    end
  end

  context "response type: JSON" do
    subject do
      Client.new(
        url: config[:url],
        api_key: user[:api_key],
        secret_key: user[:secret_key],
        json: true
      )
    end

    it_behaves_like Client

    describe "#get_row" do
      it "returns valid JSON" do
        expect {
          JSON.parse(subject.get_raw(command: :listZones))
        }.to_not raise_error
      end
    end
  end
end
