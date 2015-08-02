require 'spec_helper'

require 'infra_operator/service_proxy'
require 'infra_operator/platforms/base'

require 'infra_operator/host'

describe InfraOperator::Host do
  let(:platform_class) { Class.new { } }
  let(:backend_class) { Class.new { } }

  describe ".new" do
    context "with objects" do
      let(:platform) { platform_class.new }
      let(:backend)  { backend_class.new }

      subject { described_class.new(:platform => platform, :backend => backend) }

      it "holds given platform and backend" do
        expect(subject.platform).to eq platform
        expect(subject.backend).to eq backend
      end
    end

    context "with classes" do
      subject { described_class.new(:platform => platform_class, :backend => backend_class) }

      it "instantiates given platform class and backend class" do
        expect(subject.platform).to be_a_kind_of(platform_class)
        expect(subject.backend).to be_a_kind_of(backend_class)
      end
    end
  end

  describe "#service" do
    let(:service) { double('service') }

    let(:platform_class) do
      _service = service
      Class.new do
        def initialize(*)
          @determined = nil
        end

        define_method(:service) do |id|
          case id
          when :service
            _service
          when :not_determined
            if @determined
              _service
            else
              raise InfraOperator::Platforms::Base::NotYetDetermined
            end
          when :undetermineable
            raise InfraOperator::Platforms::Base::NotYetDetermined
          end
        end

        def determine_provider!(id, backend)
          @determined = true
        end
      end
    end

    let(:backend_class) do
      Class.new do
      end
    end

    let(:platform) { platform_class.new }
    let(:backend)  { backend_class.new }

    subject(:host) { described_class.new(:platform => platform, :backend => backend) }

    context "when service is determined" do
      subject { host.service(:service) }

      it "returns ServiceProxy" do
        expect(subject).to be_a_kind_of(InfraOperator::ServiceProxy)
        expect(subject.backend).to eq backend
        expect(subject.service).to eq service
      end
    end

    context "when service hasn't been determined and determining succeeded" do
      subject { host.service(:not_determined) }

      it "returns ServiceProxy" do
        expect(platform).to receive(:determine_provider!).with(:not_determined, backend).and_call_original

        expect(subject).to be_a_kind_of(InfraOperator::ServiceProxy)
        expect(subject.backend).to eq backend
        expect(subject.service).to eq service
      end
  end

    context "when service hasn't been determined and determining failed" do
      subject { host.service(:undetermineable) }

      it "returns ServiceProxy" do
        expect(platform).to receive(:determine_provider!).with(:undetermineable, backend).and_call_original

        expect { subject }.to raise_error(InfraOperator::Platforms::Base::NotYetDetermined)
      end
    end
  end
end
