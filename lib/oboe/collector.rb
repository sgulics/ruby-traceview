module Oboe
  class Collector
    attr_accessor :collectors
    attr_accessor :sleep_interval
    attr_accessor :time_to_exit

    def initialize
      @collectors = []
      @time_to_exit = false
      @sleep_interval = Oboe::Config[:collector][:sleep_interval]
    end

    def register(proc = nil, &block)
      if block_given?
        collectors << block
      elsif proc
        collectors << proc
      else
        raise "[oboe/collector] Neither block or proc passed to register."
      end
    end

    def start
      kvs = {}

      raise "no collectors registered" if @collectors.empty?

      Thread.new do
        while true do
          collectors.each do |b|
            kvs.merge! b.call
          end
            
          Oboe::API.start_trace('RubyMetrics', nil, { 'Force' => true, :ProcessName => Process.pid } ) do
            Oboe::API.log('RubyMetrics', 'metrics', kvs)
          end

          kvs.clear

          break if @time_to_exit
          sleep @sleep_interval
        end
      end
    rescue => e
      Oboe.logger.warn "[oboe/warn] Collector exiting on exception: #{e.message}"
      raise
    end
  end
end

Oboe.collector = ::Oboe::Collector.new
    
require 'oboe/collectors/gc'
require 'oboe/collectors/memory'
