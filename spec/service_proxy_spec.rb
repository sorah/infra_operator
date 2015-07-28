require 'spec_helper'
require 'infra_operator/service_proxy'

describe InfraOperator::ServiceProxy do
  let(:command) { double('command') }
  let(:backend) { double('backend') }
  let(:service) { double('service', operate: command) }

  subject do
    described_class.new(backend, service)
  end

  it "retrieves action from given service, then execute on given backend" do
    expect(command).to receive(:execute).with(backend).and_return(:result)

    expect(subject.operate).to eq :result
  end

  context "with arguments" do
    it "retrieves action from given service, then execute on given backend" do
      allow(service).to receive(:operate2).with(:arg0, :arg1).and_return(command)
      expect(command).to receive(:execute).with(backend).and_return(:result2)

      expect(subject.operate2(:arg0, :arg1)).to eq :result2
    end
  end
end
