# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

require 'minitest_helper'

if defined?(::Redis)
  describe "Redis Sets" do
    attr_reader :entry_kvs, :exit_kvs, :redis, :redis_version

    def min_server_version(version)
      unless Gem::Version.new(@redis_version) >= Gem::Version.new(version.to_s)
        skip "supported only on redis-server #{version} or greater"
      end
    end

    before do
      clear_all_traces

      @redis ||= Redis.new

      @redis_version ||= @redis.info["redis_version"]

      # These are standard entry/exit KVs that are passed up with all moped operations
      @entry_kvs ||= { 'Layer' => 'redis_test', 'Label' => 'entry' }
      @exit_kvs  ||= { 'Layer' => 'redis_test', 'Label' => 'exit' }
    end

    it "should trace sadd" do
      min_server_version(1.0)

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sadd("shrimp", "fried")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sadd"
      traces[2]['KVKey'].must_equal "shrimp"
    end

    it "should trace scard" do
      min_server_version(1.0)

      @redis.sadd("mother sauces", "bechamel")
      @redis.sadd("mother sauces", "veloute")
      @redis.sadd("mother sauces", "espagnole")
      @redis.sadd("mother sauces", "hollandaise")
      @redis.sadd("mother sauces", "classic tomate")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.scard("mother sauces")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "scard"
      traces[2]['KVKey'].must_equal "mother sauces"
    end

    it "should trace sdiff" do
      min_server_version(1.0)

      @redis.sadd("abc", "a")
      @redis.sadd("abc", "b")
      @redis.sadd("abc", "c")
      @redis.sadd("ab", "a")
      @redis.sadd("ab", "b")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sdiff("abc", "ab")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sdiff"
      traces[2].has_key?('KVKey').must_equal false
    end

    it "should trace sdiffstore" do
      min_server_version(1.0)

      @redis.sadd("abc", "a")
      @redis.sadd("abc", "b")
      @redis.sadd("abc", "c")
      @redis.sadd("ab", "a")
      @redis.sadd("ab", "b")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sdiffstore("dest", "abc", "ab")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sdiffstore"
      traces[2]['destination'].must_equal "dest"
    end

    it "should trace sinter" do
      min_server_version(1.0)

      @redis.sadd("abc", "a")
      @redis.sadd("abc", "b")
      @redis.sadd("abc", "c")
      @redis.sadd("ab", "a")
      @redis.sadd("ab", "b")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sinter("abc", "ab")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sinter"
      traces[2].has_key?('KVKey').must_equal false
    end

    it "should trace sinterstore" do
      min_server_version(1.0)

      @redis.sadd("abc", "a")
      @redis.sadd("abc", "b")
      @redis.sadd("abc", "c")
      @redis.sadd("ab", "a")
      @redis.sadd("ab", "b")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sinterstore("dest", "abc", "ab")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sinterstore"
      traces[2]['destination'].must_equal "dest"
    end

    it "should trace sismember" do
      min_server_version(1.0)

      @redis.sadd("fibonacci", "0")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "2")
      @redis.sadd("fibonacci", "3")
      @redis.sadd("fibonacci", "5")
      @redis.sadd("fibonacci", "8")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sismember("fibonacci", "5")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sismember"
      traces[2]['KVKey'].must_equal "fibonacci"
    end

    it "should trace smembers" do
      min_server_version(1.0)

      @redis.sadd("fibonacci", "0")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "2")
      @redis.sadd("fibonacci", "3")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.smembers("fibonacci")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "smembers"
      traces[2]['KVKey'].must_equal "fibonacci"
    end

    it "should trace smove" do
      min_server_version(1.0)

      @redis.sadd("numbers", "1")
      @redis.sadd("numbers", "2")
      @redis.sadd("alpha", "two")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.smove("alpha", "numbers", "two")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "smove"
      traces[2]['source'].must_equal "alpha"
      traces[2]['destination'].must_equal "numbers"
    end

    it "should trace spop" do
      min_server_version(1.0)

      @redis.sadd("fibonacci", "0")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "1")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.spop("fibonacci")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "spop"
      traces[2]['KVKey'].must_equal "fibonacci"
    end

    it "should trace srandmember" do
      min_server_version(1.0)

      @redis.sadd("fibonacci", "0")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "1")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.srandmember("fibonacci")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "srandmember"
      traces[2]['KVKey'].must_equal "fibonacci"
    end

    it "should trace srem" do
      min_server_version(1.0)

      @redis.sadd("fibonacci", "0")
      @redis.sadd("fibonacci", "1")
      @redis.sadd("fibonacci", "1")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.srem("fibonacci", "0")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "srem"
      traces[2]['KVKey'].must_equal "fibonacci"
    end

    it "should trace sunion" do
      min_server_version(1.0)

      @redis.sadd("group1", "moe")
      @redis.sadd("group1", "curly")
      @redis.sadd("group2", "larry")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sunion("group1", "group2")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sunion"
      traces[2].has_key?('KVKey').must_equal false
    end

    it "should trace sunionstore" do
      min_server_version(1.0)

      @redis.sadd("group1", "moe")
      @redis.sadd("group1", "curly")
      @redis.sadd("group2", "larry")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sunionstore("dest", "group1", "group2")
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sunionstore"
      traces[2]['destination'].must_equal "dest"
      traces[2].has_key?('KVKey').must_equal false
    end

    it "should trace sscan" do
      min_server_version(2.8)

      @redis.sadd("group1", "moe")
      @redis.sadd("group1", "curly")

      TraceView::API.start_trace('redis_test', '', {}) do
        @redis.sscan("group1", 1)
      end

      traces = get_all_traces
      traces.count.must_equal 4
      traces[2]['KVOp'].must_equal "sscan"
      traces[2]['KVKey'].must_equal "group1"
    end
  end
end
