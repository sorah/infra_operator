require 'infra_operator/backends/base'
require 'infra_operator/command_result'

require 'fileutils'
require 'sfl'

module InfraOperator
  module Backends
    class Exec < Base
      READ_CANCEL_EXCEPTIONS = if defined? IO::ReadWaitable
        [EOFError, IO::ReadWaitable]
      else
        [EOFError, Errno::EWOULDBLOCK, Errno::EAGAIN, Errno::EINTR]
      end

      def self.native?
        # Native flag is turned on on Native backend
        false
      end

      def self.shell?
        true
      end

      def execute_script!(script)
        # Assume you're surprised why this method is doing complex stuff --
        # we may execute scripts that starts daemon, and they may not close
        # stdout, stderr. In such situations, execute_script! will be blocked
        # forever because we read output using simple IO#read. The following
        # lines waits single process we spawned, and read output progressively
        # while the process alives.

        stdout, stderr = '', ''

        quit_r, quit_w = IO.pipe
        out_r,  out_w  = IO.pipe
        err_r,  err_w  = IO.pipe

        th = Thread.new do
          begin
            terminate = false

            loop do
              break if terminate
              readable_ios, = IO.select([quit_r, out_r, err_r])

              if readable_ios.include?(quit_r)
                terminate = true
              end

              if readable_ios.include?(out_r)
                begin
                  while out = out_r.read_nonblock(4096)
                    stdout += out
                  end
                rescue *READ_CANCEL_EXCEPTIONS
                end
              end

              if readable_ios.include?(err_r)
                begin
                  while err = err_r.read_nonblock(4096)
                    stderr += err
                  end
                rescue *READ_CANCEL_EXCEPTIONS
                end
              end
            end
          ensure
            quit_r.close unless quit_r.closed?
            out_r.close  unless out_r.closed?
            err_r.close  unless err_r.closed?
          end
        end

        th.abort_on_exception = true

        pid = spawn(env, script, :out => out_w, :err => err_w, :unsetenv_others => true)

        out_w.close
        err_w.close

        pid, stat = Process.waitpid2(pid)

        begin
          quit_w.syswrite 1
        rescue Errno::EPIPE
        end

        th.join(2)
        th.kill if th.alive?

        CommandResult.new(:status => stat, :stdout => stdout, :stderr => stderr)
      ensure
        quit_w.close unless quit_w.closed?
      end

      def upload(src, dest)
        FileUtils.cp(src, dest)
      end

      def upload_directory(src, dest)
        FileUtils.cp_r(src, dest)
      end

      private

      ENV_NAMES_TO_EXCLUDE = %w[BUNDLER_EDITOR BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT GEM_HOME GEM_PATH GEM_CACHE]

      def env
        env = {}
        ENV.each do |k,v|
          next if ENV_NAMES_TO_EXCLUDE.include?(k)
          env[k] = v
        end
        env
      end
    end
  end
end
