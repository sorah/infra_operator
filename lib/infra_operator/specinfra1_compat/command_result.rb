require 'infra_operator/command_result'
module InfraOperator
  module Specinfra1Compat
    class CommandResult
      attr_reader :stdout, :stderr, :exit_status, :exit_signal
      def initialize(arg= {})
        case arg
        when InfraOperator::CommandResult
          options = arg

          @stdout = options.stdout
          @stderr = options.stderr
          @exit_status = options.exitstatus
          @exit_signal = options.signal
        when String
          @stdout = arg
          @stderr = ''
          @exit_status = 0
          @exit_signal = nil
        when TrueClass, FalseClass
          @stdout = ''
          @stderr = ''
          @exit_status = arg ? 0 : 1
          @exit_signal = nil
        when Hash
          @stdout = options[:stdout] || ''
          @stderr = options[:stderr] || ''
          @exit_status = options[:exitstatus] || 0
          @exit_signal = options[:exitsignal]
        else
          raise ArgumentError
        end
      end
    end
  end
end
