require 'spec_helper' 
require 'infra_operator/platforms/base'

describe InfraOperator::Platforms::Base do
  let(:provider) {
    Class.new do
      def self.suitable?
        true
      end
    end
  }

  subject(:klass) do
    _provider = provider
    Class.new(described_class) do
      provides :drink, _provider
    end
  end

  subject(:platform) do
    klass.new
  end

  describe "#service" do
    subject { platform.service(:drink) }

    it "returns service provider instance" do
      expect(subject).to be_a(provider)
    end
  end
end
