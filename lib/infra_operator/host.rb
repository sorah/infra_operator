require 'infra_operator/backends/native'

module InfraOperator
  class Host
    def initialize(options = {})
      @platform = options[:platform]
      @backend = options[:backend]

      # instantiate
      @platform = @platform.new if @platform.kind_of?(Class)
      @backend = @backend.new if @backend.kind_of?(Class)
    end

    def platform
      @platform ||= nil # TODO:
    end

    def backend
      @backend ||= InfraOperator::Backends::Native.new
    end

    def services
    end
  end
end
