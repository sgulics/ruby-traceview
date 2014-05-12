# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

GC::Profiler.enable 

require 'oboe/collectors/gc'
require 'oboe/collectors/thread'

Oboe::Loading.start_collectors

