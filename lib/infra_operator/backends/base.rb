module InfraOperator
  module Backends
    class Base
      def initialize(options = {})
        @options = {}
      end

      def self.native?
        raise NotImplementedError
      end

      def execute_script!(script)
        raise NotImplementedError
      end

      def upload(src, dest)
        raise NotImplementedError
      end

      def upload_directory(src, dest)
        raise NotImplementedError
      end
    end
  end
end
