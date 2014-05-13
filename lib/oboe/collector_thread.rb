# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  class CollectorThread < ::Thread
    def initialize(name)
      Oboe.logger.debug "[oboe/debug] Spawning CollectorThread: #{name}"
      super
    end
  end
end
