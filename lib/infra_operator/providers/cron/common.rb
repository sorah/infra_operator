require 'infra_operator/providers/base'
require 'infra_operator/commands/shell'
require 'infra_operator/command_result'

module InfraOperator
  module Providers
    module Cron
      class Common < Base
        def entry_defined?(entry, options = {})
          user = options[:user]
          user_opt = user ? ['-u', user] : []

          Commands::Shell.new do
            run "crontab", "-l", *user_opt
          end.process do |stat|
            stat.value.stdout.each_line.map(&:chomp).any? { |e| e == entry.chomp }
          end.process_specinfra1 do |stat|
            stat
          end
        end

        alias check_has_entry entry_defined?
      end
    end
  end
end
