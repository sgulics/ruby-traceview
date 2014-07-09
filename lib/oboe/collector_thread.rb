# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  class CollectorThread < ::Thread
    attr_reader :name

    def initialize(name)
      Oboe.logger.debug "[oboe/debug] Spawning CollectorThread: #{name}"
      @name = name
      super
    end
  end
end
