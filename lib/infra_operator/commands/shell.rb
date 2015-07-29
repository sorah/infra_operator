require 'infra_operator/commands/base'
require 'infra_operator/utils/shell_builder'

module InfraOperator
  module Commands
    class Shell < Base
      def initialize(*)
        super
        raise ArgumentError, 'block must be given' unless block_given?
        @script = Utils::ShellBuilder.new(&@block)
      end

      def compatible?(backend)
        backend.class.shell?
      end

      def to_s
        @script.to_s
      end

      def execute!(backend)
        backend.execute_script!(self.to_s)
      end
    end
  end
end
