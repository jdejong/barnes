# frozen_string_literal: true

require 'takwimu/notifications/base'

module Takwimu
  module Notifications
    class ActionController < Base

      def self.event_name
        "process_action.action_controller"
      end

      def self.callback(name, start, finish, unique_id, payload)
        statsd_client = Takwimu.config.statsd
        hostname = Takwimu.config.hostname

        method  = payload[:method].downcase
        status  = payload[:status]
        action  = payload[:action]
        controller    = payload[:controller].sub(/Controller$/, '').downcase
        # format  = payload[:format]

        m = "#{hostname}.controllers.#{controller}_#{action}.#{method}.#{status}"
        statsd_client.timing("#{m}.all", (finish - start) * 1000, 1.0)
        statsd_client.timing("#{m}.db", payload[:db_runtime], 1.0) if payload[:db_runtime]
        statsd_client.timing("#{m}.view", payload[:view_runtime], 1.0) if payload[:view_runtime]

      end

    end
  end
end