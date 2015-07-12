require 'spec_helper'
require 'infra_operator/backends/exec'
require 'infra_operator/command_result'

RSpec.describe InfraOperator::Backends::Exec do
  subject(:backend) { described_class.new }

  describe "#execute_script!" do
    context do
      subject(:result) { backend.execute_script!('echo hi; echo err 1>&2') }

      it { is_expected.to be_a_kind_of(InfraOperator::CommandResult) }
      it { is_expected.to be_success }

      it "passes Process::Status" do
        expect(result.status).to be_a_kind_of(Process::Status)
      end

      it "captures output" do
        expect(result.stdout).to eq("hi\n")
        expect(result.stderr).to eq("err\n")
      end
    end

    context "when command exited with non-zero status" do
      subject(:result) { backend.execute_script!('exit 1') }

      it { is_expected.to be_a_kind_of(InfraOperator::CommandResult) }
      it { is_expected.not_to be_success }

      it "has exitstatus" do
        expect(result.exitstatus).to eq 1
      end
    end

    context "when executed process launches child process like a daemon, and the daemon doesn't close stdout,err" do
      subject(:result) { backend.execute_script!("ruby -e 'pid = fork { sleep 10; puts :bye }; Process.detach(pid); puts pid'") }

      it "doesn't block" do
        a = Time.now
        result # exec
        b = Time.now
        expect((b-a) < 3).to be_truthy

        expect(result.stderr).to be_empty
        expect(result.stdout.chomp).to match(/\A\d+\z/)
        Process.kill :TERM, result.stdout.chomp.to_i
      end
    end

    context "when parent process (where calls the method), has bundler/ruby environment variables" do
      NAMES = %w[BUNDLER_EDITOR BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT GEM_HOME GEM_PATH GEM_CACHE]
      before do
        @orig_env = {}
        NAMES.each do |name|
          @orig_env[name] = ENV[name]
          ENV[name] = "exec_spec"
        end
      end

      after do
        NAMES.each do |name|
          ENV[name] = @orig_env[name]
        end
      end

      subject(:result) { backend.execute_script!('env') }
      let(:env_lines) { result.stdout.lines.map(&:chomp) }

      it { is_expected.to be_a_kind_of(InfraOperator::CommandResult) }
      it { is_expected.to be_success }

      it "starts child process without such environment variable" do
        NAMES.each do |name|
          expect(env_lines).not_to include(/^#{name}=/)
        end
      end
    end
  end
end
