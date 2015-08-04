require 'infra_operator/commands/base'
require 'infra_operator/command_result'

module InfraOperator
  module Commands
    class Ruby < Base
      def compatible?(backend)
        backend.native?
      end

      def execute!(backend)
        begin
          output = @block.call(backend)
        rescue Exception => e
          return CommandResult.new(:error => e)
        end

        CommandResult.new(:output => output)
      end
    end
  end
end
