module InfraOperator
  module Commands
    class Base
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

      def execute
        command_result = execute!
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
