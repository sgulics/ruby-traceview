# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

if defined?(::Unicorn)
  Oboe.collector.register do
    report_kvs = {}

    if defined?(::Raindrops::Linux)
      # Here we retrieve all Unicorn listeners (there may be more than one)
      # and we report statistics for each.
      listeners = Unicorn.listener_names

      listeners.each_with_index do |listener_addr, i|
        stats = Raindrops::Linux.tcp_listener_stats([ listener_addr ])[ listener_addr ]
        report_kvs["listener#{i}_addr"] = listener_addr
        report_kvs["listener#{i}_queued"] = stats.queued
        report_kvs["listener#{i}_active"] = stats.active
      end
    end

    report_kvs
  end
end
