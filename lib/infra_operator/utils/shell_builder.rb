require 'shellwords'

module InfraOperator
  module Utils
    class ShellBuilder
      def initialize(&block)
        @block = block
      end

      def to_s
        Context.new(&@block).to_s
      end

      class Context
        def initialize(&block)
          @block = block
          @list = []
          instance_eval &@block
        end

        attr_reader :list

        def to_s
          @list.map(&:to_s).join("\n")
        end

        def var(*args)
          @list << Variable.new(*args)
        end

        def export(*args)
          @list << Variable.new(*args).export
        end

        def cd(*args)
          @list << Chdir.new(*args)
        end

        def run(*args)
          @list << Run.new(*args)
        end

        def pipe(&block)
          @list << Context.new(&block).list.map(&:to_s).join(' | ')
        end

        def subshell(&block)
          @list << [
            '(',
            *Context.new(&block).list.map(&:to_s),
            ')',
          ].join("\n")
        end

        def with_and(&block)
          @list << Context.new(&block).list.map(&:to_s).join(' && ')
        end

        def with_or(&block)
          @list << Context.new(&block).list.map(&:to_s).join(' || ')
        end
      end

      class Run
        def initialize(*args)
          @args = args
          @options = args.last.kind_of?(Hash) ? args.pop : {}
          @args.flatten!
        end

        def command
          @args.map { |_| Shellwords.escape(_) }
        end

        def redirect
          redirects = @options.map do |k,v|
            next unless k.kind_of?(Integer) || k == :out || k == :err || k == :in
            make_redirection(k, v)
          end.compact

          redirects.empty? ? nil : redirects.join(' ')
        end

        def to_s
          [*command, *redirect].join(" ")
        end

        private

        def make_redirection(k, v)
          fd = {:in => '', :out => '', :err => 2}[k] || k

          direction = k == :in ? '<' : '>'

          if v.kind_of?(Array)
            v, orig_v = v.dup, v
            if v.first == :read
              v.shift
              direction = '<'
            end

            if v.first == :rw
              v.shift
              direction = '<>'
            end

            if v.first == :append
              v.shift
              direction = '>>'
            end

            unless v.size == 1
              raise ArgumentError, "invalid redirect (#{k.inspect} => #{orig_v.inspect})"
            end

            v = v.first
          end

          if v.kind_of?(Integer)
            dest = "&#{v}"
          else
            dest = Shellwords.escape(v.to_s)
          end

          [fd, direction, dest].join
        end
      end

      class Chdir
        def initialize(destination)
          @destination = destination
        end

        def to_s
          "cd #{Shellwords.escape(@destination)}"
        end
      end

      class Variable
        def initialize(variables = {})
          @variables = variables
          @export = variables.delete(:export)
        end

        def export
          self.class.new(@variables.merge(:export => true))
        end

        def escaped_variable_definitions
          @variables.map { |k, v| "#{@export ? 'export ' : nil}#{Shellwords.shellescape(k)}=#{Shellwords.shellescape(v)}" }
        end

        def to_s
          escaped_variable_definitions.join("\n")
        end
      end
    end
  end
end
