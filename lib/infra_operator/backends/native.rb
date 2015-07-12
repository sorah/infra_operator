require 'infra_operator/backends/exec'

module InfraOperator
  module Backends
    class Native < Exec
      def self.native?
        true
      end
    end
  end
end
