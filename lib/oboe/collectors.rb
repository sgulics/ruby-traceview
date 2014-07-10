# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

if Oboe.loaded and ENV['RACK_ENV'] != 'test'
  require 'oboe/collectors/gc'
  require 'oboe/collectors/memory'
end

