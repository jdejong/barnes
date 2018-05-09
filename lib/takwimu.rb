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
  # DEFAULT_INTERVAL           = 10
  # DEFAULT_AGGREGATION_PERIOD = 60
  # DEFAULT_STATSD             = :default
  # DEFAULT_PANELS             = []
  # DEFAULT_HOSTNAME           = "#{Socket.gethostname}"

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Takwimu::Configuration.new
  end

  def self.reset
    @config = Takwimu::Configuration.new
  end

  def self.configure
    yield(config)
  end

  # Starts the reporting client
  #
  # Arguments:
  #
  #   - interval: How often, in seconds, to instrument and report
  #   - aggregation_period: The minimal aggregation period in use, in seconds.
  #   - statsd: The statsd reporter. This should be an instance of statsd-ruby
  #   - panels: The instrumentation "panels" in use. See `resource_usage.rb` for
  #     an example panel, which is the default if none are provided.
  def self.start() #interval: Takwimu.config.interval, aggregation_period: Takwimu.config.aggregation_period, statsd: Takwimu.config.statsd, panels: Takwimu.config.panels, hostname: Takwimu.config.hostname)
    require 'statsd'
    statsd_client = Takwimu.config.statsd
    panels        = Takwimu.config.panels
    sample_rate   = Takwimu.config.interval.to_f / Takwimu.config.aggregation_period.to_f
    hostname = Takwimu.config.hostname

    if statsd_client == :default && ENV["PORT"]
      statsd_client = Statsd.new('127.0.0.1', ENV["PORT"])
    end

    if statsd_client && statsd_client != :default
      reporter = Takwimu::Reporter.new(statsd: statsd_client, sample_rate: sample_rate, hostname: hostname)

      unless panels.length > 0
        panels << Takwimu::ResourceUsage.new(sample_rate)
      end

      #Rails.logger.info "#{panels.inspect}"

      Periodic.new reporter: reporter, sample_rate: sample_rate, panels: panels
    end
  end
end

require 'takwimu/reporter'
require 'takwimu/resource_usage'
require 'takwimu/periodic'
require 'takwimu/railtie' if defined? ::Rails::Railtie
require 'takwimu/configuration'
