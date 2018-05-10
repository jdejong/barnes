# frozen_string_literal: true

require 'active_support'

module Takwimu
  module Notifications
    class Base
      def self.subscribe!
        subscription = ActiveSupport::Notifications.subscribe(event_name, &method(:callback))

        subscription
      end

      def self.callback
        raise "#handle not implemented"
      end
    end
  end
end