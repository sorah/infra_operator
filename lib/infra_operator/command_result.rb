module InfraOperator
  class CommandResult
    def initialize(properties = {})
      @properties = properties
    end

    def output
      @properties[:output].to_s || stdout
    end

    def stdout
      @properties[:stdout]
    end

    def stderr
      @properties[:stderr]
    end

    def status
      @properties[:status]
    end

    def pid
      refer_stat_or_property(:pid)
    end

    def exitstatus
      refer_stat_or_property(:exitstatus)
    end

    def signal
      @properties[:signal] || termsig || stopsig
    end

    def stopsig
      refer_stat_or_property(:stopsig)
    end

    def termsig
      refer_stat_or_property(:termsig)
    end

    def success?
      !error && (@properties[:success] || (exitstatus == 0))
    end

    def signaled?
      status ? status.signaled? : !!signal
    end

    def exited?
      status ? status.exited? : @properties[:exited]
    end

    def coredump?
      status ? status.coredump? : @properties[:coredump]
    end

    def error
      @properties[:error]
    end

    private

    def refer_stat_or_property(name)
      status ? status.__send__(name) : @properties[name]
    end
  end
end
