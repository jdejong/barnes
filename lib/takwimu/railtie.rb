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

require 'rails/railtie'
require 'takwimu/notifications/action_controller'
require 'takwimu/notifications/active_record'

module Takwimu
  # Automatically configures barnes to run with
  # rails 3, 4, and 5. Configuration can be changed
  # in the application.rb. For example
  #
  #   module YourApp
  #     class Application < Rails::Application
  #     config.barnes[:interval] = 20
  #
  class Railtie < ::Rails::Railtie

    initializer 'takwimu' do |app|

      Takwimu.configure do |config|
        config.logger = Rails.logger
      end

      #Start thread to send periodic stats
      Takwimu.start

      #Subscribe for per request stats
      Takwimu::Notifications::ActionController.subscribe!
      Takwimu::Notifications::ActiveRecord.subscribe!

    end
  end
end
