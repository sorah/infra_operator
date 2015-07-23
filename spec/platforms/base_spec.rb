require 'spec_helper' 
require 'infra_operator/platforms/base'

describe InfraOperator::Platforms::Base do
  let(:provider) {
    Class.new do
      def self.suitable?(backend)
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

  describe "#provides?" do
    it "returns true for provided service" do
      expect(platform.provides?(:drink)).to be_truthy
    end

    it "returns false for non-provided service" do
      expect(platform.provides?(:pizza)).to be_falsey
    end
  end

  context "with dynamic provider (Array)" do
    let(:service_a) { Class.new { } }
    let(:service_b) { Class.new { } }

    let(:backend)   { double('backend') }

    subject(:klass) do
      _service_a, _service_b = service_a, service_b
      Class.new(described_class) do
        provides :service, [_service_a, _service_b]
      end
    end

    context "when not determined" do
      describe "#service" do
        it "raises NotYetDetermined" do
          expect {
            platform.service(:service)
          }.to raise_error(InfraOperator::Platforms::Base::NotYetDetermined)
        end
      end
    end

    context "when determined" do
      before do
        expect(service_a).to receive(:suitable?).with(backend).and_return(true)
        expect(service_b).not_to receive(:suitable?)

        platform.determine_providers!(backend)
      end

      it "returns determined service" do
        expect(platform.service(:service)).to be_a(service_a)
      end
    end

    context "when determined (2)" do
      before do
        expect(service_a).to receive(:suitable?).with(backend).and_return(false)
        expect(service_b).to receive(:suitable?).with(backend).and_return(true)

        platform.determine_providers!(backend)
      end

      it "returns determined service" do
        expect(platform.service(:service)).to be_a(service_b)
      end
    end
  end
end
