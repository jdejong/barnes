# frozen_string_literal: true

module Takwimu
  module Instruments
    class RailsRequest
      def initialize(sample_rate=nil)
      end

      def valid?
        defined?(Rails)
      end

      def instrument!(state, counters, gauges, timers)
        Takwimu.config.logger.debug "Takwimu.PassengerStats.instrument!" if Takwimu.config.logger

        if controller = env['action_controller.instance']
          name    = controller.controller_name
          action  = controller.action_name
          format  = controller.try(:rendered_format) || :none
          variant = controller.try(:request).try(:variant) || :none  # Rails 4.1+ only!

          timers[ :"actions.#{name}.#{action}.#{format}+#{variant}" ]
        end

      end
    end
  end
end