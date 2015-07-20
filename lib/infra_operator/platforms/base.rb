module InfraOperator
  module Platforms
    class Base
      class BackendRequiredToDetermine < StandardError; end
      class NotYetDetermined < StandardError; end

      def initialize(options={})
        @options = options
        @services = {}
        @service_classes = self.class.services.dup

        override_services!
      end

      attr_reader :options

      def self.services
        @services ||= {}
      end

      def self.provides(service, provider)
        services[service] = self.resolve_provider_class(service, provider)
      end

      def self.resolve_provider_class(service, provider)
        case provider
        when Class
          provider
        when Symbol, String
          retried = false
          begin
            provider_const_name = provider.to_s.capitalize.gsub(/_./) { |_| _[1].upcase }
            service_const_name = service.to_s.capitalize.gsub(/_./) { |_| _[1].upcase }
            InfraOperator::Providers.const_get(service_const_name).const_get(provider_const_name)
          rescue NameError
            raise if retried
            require "infra_operator/providers/#{service}/#{provider}"
            retried = true
            retry
          end
        when Array
          provider.map { |_| resolve_provider_class(_) }
        end
      end

      def service(id)
        case
        when @services.key?(id)
          return @services[id] 
        when @service_classes.key?(id)
          begin
            determine_provider!(id)
            @services[id]
          rescue BackendRequiredToDetermine
            raise NotYetDetermined
          end
        else
          nil
        end
      end

      def provides?(id)
        @service_classes.key? id
      end

      def determine_providers!(backend)
        @service_classes.each_key do |id|
          determine_providers! backend, id
        end
      end

      def determine_provider!(id, backend = nil)
        return if @services[id]
        return unless @service_classes[id]

        candidate = @service_classes[id]
        case candidate
        when Class
          @services[id] = candidate.new
        when Proc
          raise BackendRequiredToDetermine unless backend
          @services[id] = candidate.call(self, backend)
        when Array
          raise BackendRequiredToDetermine unless backend
          candidate.each do |_|
            if _.suitable?(backend)
              @services[id] = _.new
              break
            end
          end
        else
          raise TypeError
        end
      end

      private

      def override_services!
        spec = options[:services] || {}

        spec.each do |k, v|
          @service_classes[k] = self.class.resolve_provider_class(k, v)
        end
      end
    end
  end
end
