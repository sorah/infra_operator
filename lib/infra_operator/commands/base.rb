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
      
      # Specify block to tranform result. Passed block will be used on execute method
      def process(&block)
        @processor = block
        self
      end

      def execute(backend)
        unless self.compatible?(backend)
          raise BackendIncompatibleError
        end

        command_result = execute!(backend)
        if @processor
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
