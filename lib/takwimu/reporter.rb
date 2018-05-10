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

module Takwimu
  # The reporter is used to send stats to the server.
  #
  # Example:
  #
  #   statsd   = Statsd.new('127.0.0.1', "8125")
  #   reporter = Reporter.new(statsd: , sample_rate: 10)
  #   reporter.report_statsd('barnes.counters' => {"hello" => 2})
  class Reporter
    attr_accessor :statsd, :sample_rate, :hostname

    def initialize(statsd: , sample_rate:, hostname:)
      @statsd      = statsd
      @sample_rate = sample_rate.to_f
      @hostname = hostname

      if @statsd.respond_to?(:easy)
        @statsd_method = statsd.method(:easy)
      else
        @statsd_method = statsd.method(:batch)
      end
    end

    def report(env)
      report_statsd env if @statsd
    end

    def report_statsd(env)
      @statsd_method.call do |statsd|
        env[Takwimu::COUNTERS].each do |metric, value|
          statsd.count(:"#{hostname}.rack.#{metric}", value, @sample_rate)
        end

        # for :gauge, use sample rate of 1, since gauges in statsd have no sampling characteristics.
        env[Takwimu::GAUGES].each do |metric, value|
          statsd.gauge(:"#{hostname}.rack.#{metric}", value, 1.0)
        end

        env[Takwimu::TIMERS].each do |metric, value|
          statsd.timing(:"#{hostname}.rack.#{metric}", value, 1.0)
        end
      end
    end
  end
end
