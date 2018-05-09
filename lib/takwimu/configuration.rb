

module Takwimu
  class Configuration

    attr_accessor :interval, :aggregation_period, :statsd, :hostname, :logger, :panels


    def initialize
      @interval = 10
      @aggregation_period = 60
      @statsd = :default
      @hostname = "#{Socket.gethostname}"
      @logger = nil
      @panels = []
    end

  end
end