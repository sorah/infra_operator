require 'infra_operator/backends/native'
require 'infra_operator/platforms/base'
require 'infra_operator/service_proxy'

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

    def service(id)
      retried = false
      begin
        svc = @platform.service(id)
      rescue InfraOperator::Platforms::Base::NotYetDetermined
        raise if retried

        @platform.determine_provider!(id, backend)

        retried = true
        retry 
      end

      if svc
        ServiceProxy.new(backend, svc)
      else
        nil
      end
    end
  end
end
