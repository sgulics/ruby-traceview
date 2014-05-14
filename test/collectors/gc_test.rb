if RUBY_VERSION >= '1.9.3'
  require 'minitest_helper'
      
  GC::Profiler.enable

  describe Oboe::Collectors::GC do
    before do
      clear_all_traces 
    end

    after do
    end

    it 'should be loaded, defined and ready' do
      defined?(::Oboe::Collectors::GC).wont_match nil 
    end

    it 'should have correct default Oboe::Config values' do
      Oboe::Config[:collectors][:gc][:enabled].must_equal true
      Oboe::Config[:collectors][:gc][:sleep_interval].must_equal 60
    end

    it 'should generate GC metric traces' do

      gc_collector = ::Oboe::Collectors::GC.new
      gc_collector.time_to_exit = true
      gc_collector.perform

      traces = get_all_traces
      traces.count.must_equal 3

      validate_outer_layers(traces, 'RubyGC')

      traces[1]['Layer'].must_equal "RubyGC"
      traces[1]['Label'].must_equal "metrics"
      traces[1].has_key?('count').must_equal true 
      traces[1].has_key?('heap_used').must_equal true 
      traces[1]['RubyVersion'].must_equal RUBY_VERSION
    end
  end
end
