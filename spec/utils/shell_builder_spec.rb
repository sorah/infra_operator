require 'spec_helper'
require 'infra_operator/utils/shell_builder'

RSpec.describe InfraOperator::Utils::ShellBuilder do
  def build(&block)
    described_class.new(&block).to_s
  end

  describe "var" do
    subject { build { var('foo' => 'bar baz', 'hoge' => 'fuga') }.chomp.split(/; /) }

    it { is_expected.to include("foo=bar\\ baz") }
    it { is_expected.to include("hoge=fuga") }
  end

  describe "export" do
    subject { build { export('foo' => 'bar baz', 'hoge' => 'fuga') }.chomp.split(/; /)  }

    it { is_expected.to include("export foo=bar\\ baz") }
    it { is_expected.to include("export hoge=fuga") }
  end

  describe "cd" do
    context "simple" do
      subject { build { cd "/tmp" } }
      it { is_expected.to eq "cd /tmp" }
    end

    context "with spaces" do
      subject { build { cd "/tmp tmp" } }
      it { is_expected.to eq "cd /tmp\\ tmp" }
    end
  end

  describe "run" do
    context "simple" do
      subject { build { run 'foo', 'bar', '1 2' } }
      it { is_expected.to eq "foo bar 1\\ 2" }
    end

    context "array" do
      subject { build { run %w(foo bar) } }
      it { is_expected.to eq "foo bar" }
    end

    context "array and values" do
      subject { build { run %w(foo bar), 'baz' } }
      it { is_expected.to eq "foo bar baz" }
    end

    context "redirection" do
      subject(:script) do
        build do
          run(
            'foo',
            {
              :in => 'in.txt',
              :out => 'out.txt',
              :err => 'err.txt',
              10 => '10.txt',
              21 => [:read, '21.txt'],
              22 => [:rw, '22.txt'],
              23 => [:append, '23.txt'],
              31 => 91,
              32 => [:read, 92],
              33 => [:rw, 93],
              40 => 'foo bar.txt',
            }
          )
        end
      end

      subject(:splitted_subject) { script.shellsplit }

      specify {
        expect(splitted_subject.size).to eq 12
        expect(splitted_subject.first).to eq 'foo'
        expect(splitted_subject).to include('<in.txt')
        expect(splitted_subject).to include('>out.txt')
        expect(splitted_subject).to include('2>err.txt')
        expect(splitted_subject).to include('10>10.txt')
        expect(splitted_subject).to include('21<21.txt')
        expect(splitted_subject).to include('22<>22.txt')
        expect(splitted_subject).to include('23>>23.txt')
        expect(splitted_subject).to include('31>&91')
        expect(splitted_subject).to include('32<&92')
        expect(splitted_subject).to include('33<>&93')
        expect(splitted_subject).to include("40>foo bar.txt")
        expect(script).to include("40>foo\\ bar.txt")
      }
    end
  end

  describe "pipe" do
    subject do
      build do
        pipe do
          run 'a'
          run 'b'
        end
      end
    end

    it { is_expected.to eq "a | b" }
  end

  describe "subshell" do
    subject do
      build do
        subshell do
          run 'a'
          run 'b'
        end
      end
    end

    it { is_expected.to eq "( a; b )" }
  end

  describe "with_and" do
    subject do
      build do
        with_and do
          run 'a'
          run 'b'
        end
      end
    end

    it { is_expected.to eq "a && b" }
  end

  describe "with_or" do
    subject do
      build do
        with_or do
          run 'a'
          run 'b'
        end
      end
    end

    it { is_expected.to eq "a || b" }
  end

  context  do
    subject do
      build do
        cd '/tmp'
        export 'foo' => 'bar'

        run 'a', 'hello', 'world'

        subshell do
          run 'b.a'
          run 'b.b'

          pipe do
            run 'b.c.a'
            run 'b.c.b'
          end
        end

        with_and do
          run 'c.a'
          run 'c.b'
          with_or do
            run 'c.c.a'
            run 'c.c.b'
          end
        end
      end
    end

    specify "complex one" do
      expect(subject).to eq(<<-EOF.lines.map(&:chomp).join(' '))
cd /tmp;
export foo=bar;
a hello\ world;
(
b.a;
b.b;
b.c.a | b.c.b
);
c.a && c.b && c.c.a || c.c.b
      EOF
    end
  end
end
