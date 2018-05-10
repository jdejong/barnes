# frozen_string_literal: true

require 'takwimu/notifications/base'

module Takwimu
  module Notifications
    class ActiveRecord < Base

      def self.event_name
        "sql.active_record"
      end

      def self.callback(name, start, finish, unique_id, payload)
        statsd_client = Takwimu.config.statsd
        hostname = Takwimu.config.hostname

        case payload[:sql]
          when /^SELECT/
            payload[:sql] =~ SELECT_DELETE
            $statsd.increment("#{hostname}.sql.select")
            $statsd.timing("#{hostname}.sql.#{$1}.select.query_time", (finish - start) * 1000, 1)
          when /^DELETE/
            payload[:sql] =~ SELECT_DELETE
            $statsd.increment("#{hostname}.sql.delete")
            $statsd.timing("#{hostname}.sql.#{$1}.delete.query_time", (finish - start) * 1000, 1)
          when /^INSERT/
            payload[:sql] =~ INSERT
            $statsd.increment("#{hostname}.sql.insert")
            $statsd.timing("#{hostname}.sql.#{$1}.insert.query_time", (finish - start) * 1000, 1)
          when /^UPDATE/
            payload[:sql] =~ UPDATE
            $statsd.increment("#{hostname}.sql.update"  )
            $statsd.timing("#{hostname}.sql.#{$1}.update.query_time", (finish - start) * 1000, 1)
        end
      end
    end
  end
end