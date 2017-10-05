require_relative '../helper'

require 'yajl'
require 'flexmock/test_unit'

require 'fluent/command/cat'
require 'fluent/event'

class TestCatCommand < ::Test::Unit::TestCase
  def suppress_stdout
    out = StringIO.new
    $stdout = out
    yield
  ensure
    $stdout = STDOUT
  end
  sub_test_case 'initialize' do
    data(
      empty: [],
      without_tag: %w(-f json),
      port_not_specified: %w(-p x.y.z)
    )
    test 'should fail when tag is not passed' do |argv|
      assert_raise(SystemExit) do
        suppress_stdout { CatCommand.new(argv) }
      end
    end

    data(
      all_options: %w(-p 42 -h localhost -u -s /var/run/fluent/fluent.sock -f none --message-key x --time-as-integer x.y.z),
      only_tag: %w(x.y.z)
    )
    test 'should succeed when options are valid' do |argv|
      assert_nothing_raised do
        CatCommand.new(argv)
      end
    end

    data(
      json: ['json', %w(-f json x)],
      msgpack: ['msgpack', %w(-f msgpack y)],
      none: ['none', %w(-f none z)]
    )
    test 'should keep specified format' do |data|
      format, argv = data
      command = CatCommand.new(argv)
      assert_equal(format, command.format)
    end
  end
end
