# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

if defined?(::Unicorn)
  Oboe.collector.register do
    report_kvs = {}

    if defined?(::Raindrops::Linux)
      listener_addr = '0.0.0.0:' + ENV['PORT']
      stats = Raindrops::Linux.tcp_listener_stats([ listener_addr ])[listener_addr]

      report_kvs[:addr] = Oboe::Util.getaddr
      report_kvs[:queued] = stats.queued
      report_kvs[:active] = stats.active
    end

    report_kvs
  end
end
