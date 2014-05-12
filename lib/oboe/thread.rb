# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  module CollectorThread < ::Thread
    def initialize(name)
      Oboe.logger.debug "Creating CollectorThread: #{name}"
      super
    end
  end
end
