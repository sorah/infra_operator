require 'infra_operator/providers/base'
require 'infra_operator/commands/shell'
require 'infra_operator/command_result'

module InfraOperator
  module Providers
    module File
      class Bsd < Base
        def is_accessible_by_user?(file, user, access)
          Commands::Shell.new do
            run 'sudo', '-u', user, '-s', '/bin/test', "-#{access}", file
          end.process do |stat|
            stat.success?
          end
        end

        alias check_is_accessible_by_user is_accessible_by_user?

        def md5sum(file)
          Commands::Shell.new do
            pipe do
              run 'openssl', 'md5', file
            end
          end.process do |stat|
            stat.value.stdout.chomp[-32..-1]
          end.process_specinfra1 do |sum|
            {:stdout => sum}
          end
        end

        alias get_md5sum md5sum

        def sha256sum(file)
          Commands::Shell.new do
            pipe do
              run 'openssl', 'dgst', '-sha256', file
            end
          end.process do |stat|
            stat.value.stdout.chomp[-64..-1]
          end.process_specinfra1 do |sum|
            {:stdout => sum}
          end
        end

        alias get_sha256sum sha256sum

        def is_linked_to?(link, target)
          Commands::Shell.new do
            run "stat", "-f", "%Y", link
          end.process do |stat|
            stat.value.stdout.chomp == target
          end.process_specinfra1 do |result|
            result
          end
        end

        alias check_is_linked_to is_linked_to?

        def has_mode?(file, mode)
          Commands::Shell.new do
            run "stat", "-f", "%p", file
          end.process do |stat|
            stat.value.stdout.chomp[-4..-1] == mode.rjust(4, '0')
          end.process_specinfra1 do |result|
            result
          end
        end

        alias check_has_mode has_mode?

        def is_owned_by?(file, owner)
          Commands::Shell.new do
            run "stat", "-f", "%Su", file
          end.process do |stat|
            stat.value.stdout.chomp == owner
          end.process_specinfra1 do |result|
            result
          end
        end

        alias check_is_owned_by is_owned_by?

        def is_owned_by_group?(file, owner) # XXX:
          Commands::Shell.new do
            run "stat", "-f", "%Sg", file
          end.process do |stat|
            stat.value.stdout.chomp == owner
          end.process_specinfra1 do |result|
            result
          end
        end

        alias check_is_owned_by is_owned_by_group?

        def mode(file)
          Commands::Shell.new do
            run "stat", "-f", "%p", file
          end.process do |stat|
            stat.value.stdout.chomp[-4..-1]
          end.process_specinfra1 do |fourdigit_mode|
            fourdigit_mode[-3..-1]
          end
        end

        alias get_mode mode

        def owner(file)
          Commands::Shell.new do
            pipe do
              run "stat", "-f", "%Su", file
            end
          end.process do |stat|
            stat.value.stdout.chomp
          end
        end

        alias get_owner owner

        def group(file)
          Commands::Shell.new do
            pipe do
              run "stat", "-f", "%Sg", file
            end
          end.process do |stat|
            stat.value.stdout.chomp
          end
        end

        alias get_group owner
      end
    end
  end
end
