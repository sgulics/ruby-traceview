require 'minitest_helper'

describe Oboe::Collectors::Memory do
  before do
    clear_all_traces
  end

  after do
  end

  it 'should be loaded, defined and ready' do
    defined?(::Oboe::Collectors::Memory).wont_match nil
  end

  it 'should have correct default Oboe::Config values' do
    Oboe::Config[:collectors][:memory][:enabled].must_equal true
    Oboe::Config[:collectors][:memory][:sleep_interval].must_equal 120
  end

  it 'should generate Memory metric traces' do

    memory_collector = ::Oboe::Collectors::Memory.new
    memory_collector.time_to_exit = true
    memory_collector.perform

    traces = get_all_traces
    traces.count.must_equal 3

    validate_outer_layers(traces, 'RubyMemory')

    traces[1]['Layer'].must_equal "RubyMemory"
    traces[1]['Label'].must_equal "metrics"
    traces[1].has_key?('ThreadCount').must_equal true
    traces[1].has_key?('VmRSS').must_equal true
  end
end
