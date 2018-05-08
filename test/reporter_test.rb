require 'takwimu/test_helper'
require 'takwimu/reporter'
require 'logger'
require 'stringio'

class ReporterTest < Minitest::Test
  class Statsd
    def initialize(batcher)
      @batcher = batcher
    end
    def batch
      yield @batcher
    end
  end

  def test_report_statsd
    batch = MiniTest::Mock.new

    batch.expect :count, true, [:'Rack.Server.All.GC.allocated_objects', 10, 1.0]
    batch.expect :gauge, true, [:'Rack.Server.All.Time.pct.cpu', 9.1, 1.0]

    statsd = Statsd.new batch

    reporter = Takwimu::Reporter.new(statsd: statsd, sample_rate: 1)
    reporter.report_statsd \
                Takwimu::COUNTERS => { :'GC.allocated_objects' => 10 }, \
                Takwimu::GAUGES => { :'Time.pct.cpu' => 9.1 }

    batch.verify
  end
end
