module InfraOperator
  class ServiceProxy
    def initialize(backend, service)
      @backend = backend
      @service = service
    end

    attr_reader :backend, :service

    def method_missing(meth, *args)
      command = service.__send__(meth, *args)
      command.execute backend
    end
  end
end
