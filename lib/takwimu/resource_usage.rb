# Copyright (c) 2017 Salesforce
# Copyright (c) 2009 37signals, LLC
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'takwimu/panel'

module Takwimu
  class ResourceUsage < Panel
    def initialize(sample_rate)
      super()

      require 'takwimu/instruments/puma_backlog'
      backlog_reporter = Takwimu::Instruments::PumaBacklog.new

      if backlog_reporter.valid?
        instrument backlog_reporter
      end

      require 'takwimu/instruments/passenger_stats'
      passenger_stats_reporter = Takwimu::Instruments::PassengerStats.new

      if passenger_stats_reporter.valid?
        instrument passenger_stats_reporter
      end


      require 'takwimu/instruments/stopwatch'
      instrument Takwimu::Instruments::Stopwatch.new

      if GC.respond_to? :enable_stats
        require 'takwimu/instruments/ree_gc'
        instrument Takwimu::Instruments::Ruby18GC.new
      end

      # Ruby 1.9+
      if ObjectSpace.respond_to? :count_objects
        require 'takwimu/instruments/object_space_counter'
        instrument Takwimu::Instruments::ObjectSpaceCounter.new
      end

      # Ruby 1.9+
      if GC.respond_to?(:stat)
        require 'takwimu/instruments/ruby_gc'
        instrument Takwimu::Instruments::RubyGC.new(sample_rate)
      end

      # Ruby 2.1+ with https://github.com/tmm1/gctools
      if defined? GC::OOB
        require 'takwimu/instruments/gctools_oobgc'
        instrument Takwimu::Instruments::GctoolsOobgc.new
      end
    end
  end
end
