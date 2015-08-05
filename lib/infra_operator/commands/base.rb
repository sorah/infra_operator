require 'infra_operator/specinfra1_compat/command_result'

module InfraOperator
  module Commands
    class Base
      class BackendIncompatibleError < StandardError; end

      def initialize(options = {}, &block)
        @options = options
        @block = block
      end

      def compatible?(backend)
        raise NotImplementedError
      end

      # Compile command to string. May be unsupported on some subclass
      def to_s
        raise NotImplementedError
      end
      
      # Specify processor block to tranform raw CommandResult. Passed block will be used on execute method
      def process(&block)
        @processor = block
        self
      end

      # Specify block to transform processor result for specinfra v1 API. Block should return CommandResult.
      def process_specinfra1(&block)
        @specinfra1_processor = block
        self
      end

      def execute_specinfra1(backend)
        if @specinfra1_processor
          Specinfra1Compat::CommandResult.new @specinfra1_processor.call(execute(backend))
        else
          Specinfra1Compat::CommandResult.new execute(backend, :raw => true)
        end
      end

      def execute(backend, options = {})
        unless self.compatible?(backend)
          raise BackendIncompatibleError
        end

        command_result = execute!(backend)
        if @processor && !options[:raw]
          @processor.call(command_result)
        else
          command_result
        end
      end

      # Execute command.
      def execute!(backend)
        raise NotImplementedError
      end
    end
  end
end
