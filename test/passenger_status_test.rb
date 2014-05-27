require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../lib/status_parser')
require "nokogiri"

class PassengerStatusTest < Test::Unit::TestCase

  def setup
    example_output_file = File.join(File.dirname(__FILE__), 'test_commands/passenger-status --show=xml')
    @status_parser = Status.new(File.read(example_output_file))
  end

  test "max possible passenger processes are parsed correctly" do
    assert_equal 6, @status_parser.max
  end

  test "number of running passenger processes are parsed correctly" do
    assert_equal 6, @status_parser.current
  end

  test "requests waiting on global queue are parsed correctly" do
    assert_equal 3, @status_parser.queue
  end

  test "number of sessions (summed as total) parsed correctly" do
    assert_equal 1, @status_parser.sessions
  end

  test "CPU (summed as total) parsed correctly" do
    assert_equal 4.5, @status_parser.cpu
  end

  test "memory by app parsed correctly" do
    assert_equal 55620, @status_parser.process_memory['23882']
  end

  test "time since last used parsed correctly" do
    assert 5670 < @status_parser.last_used_time["1"]
  end

end
