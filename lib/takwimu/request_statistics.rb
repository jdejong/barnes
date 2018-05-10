
require 'takwimu/panel'

module Takwimu
  class RequestStatisitcs < Panel
    def initialize(sample_rate)
      super()

      require 'takwimu/instruments/rails_request'
      rails_request_reporter = Takwimu::Instruments::RailsRequest.new

      if rails_request_reporter.valid?
        Takwimu.config.logger.debug "Takwimu.RequestStatisitcs.initialize - Setting up Rails Instrumentation" if Takwimu.config.logger
        instrument rails_request_reporter
      end
    end
  end
end