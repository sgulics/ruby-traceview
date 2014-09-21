# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

if defined?(::GC::Profiler) and ::GC::Profiler.enabled?
  Oboe.collector.register do
    report_kvs = {}
    kvs = [ :count, :minor_gc_count, :major_gc_count, :total_time, :total_allocated_object,
            :total_freed_object, :heap_live_slot, :heap_live_num, :heap_free_slot, :head_free_num ]

    report_kvs[:RubyVersion] = RUBY_VERSION
    report_kvs[:total_time] = ::GC::Profiler.total_time

    report_kvs = ::GC.stat.select{ |k, v| kvs.include?(k) }
    report_kvs
  end
end
