require 'infra_operator/platforms/base'

module InfraOperator
  module Platforms
    module Osx
      class Common < Base
        provides :file, :bsd
        provides :cron, :common
        provides :user, :bsd
        provides :group, :bsd
        provides :service, :launchd
        provides :package, :osx
      end
    end
  end
end
