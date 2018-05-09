# frozen_string_literal: true

module Takwimu
  module Instruments
    class PassengerStats

      PROCESS_ELEMENTS = %w(concurrency sessions busyness processed rss pss private_dirty swap real_memory cpu vmsize)

      def initialize(sample_rate=nil)
      end

      def valid?
        defined?(PhusionPassenger)
      end

      def start!(state)

      end

      def json_stats
        doc = Nokogiri::XML(`sudo /usr/sbin/passenger-status --show=xml`)

        stats = {
            process_count: doc.xpath('//process_count').children[0].to_s,
            max_pool_size: doc.xpath('//max').children[0].to_s,
            capacity_used: doc.xpath('//capacity_used').children[0].to_s,
            top_level_queue: doc.xpath('//get_wait_list_size').children[0].to_s,
            processes: []
        }

        doc.xpath('//supergroups')[0].xpath('./supergroup').each do |supergroup|
          supergroup.xpath('./group/processes/process').each_with_index do |process, i|

            process_element = {}
            PROCESS_ELEMENTS.each do |element|
              process_element[element.to_sym] = process.xpath("./#{element}").children[0].to_s
            end
            stats[:processes][i] = process_element
          end
        end

        return stats
      rescue StandardError => e
        #raise e unless e.message =~ /nil/
        #raise e unless e.message =~ /stats/
        Takwimu.config.logger.error "Takwimu.PassengerStats #{e.message}" if Takwimu.config.logger
        return {}
      end

      def instrument!(state, counters, gauges)
        Takwimu.config.logger.debug "Takwimu.PassengerStats.instrument!" if Takwimu.config.logger
        stats = self.json_stats

        Takwimu.config.logger.debug "Takwimu.PassengerStats.instrument! Stats - #{stats.inspect}" if Takwimu.config.logger

        return if stats.empty?

        gauges[:"passenger.process_count"] = stats[:process_count]
        gauges[:"passenger.max_pool_size"] = stats[:max_pool_size]
        gauges[:"passenger.capacity_used"] = stats[:capacity_used]
        gauges[:"passenger.top_level_queue"] = stats[:top_level_queue]

        stats[:processes].each_with_index do |process, i|
          PROCESS_ELEMENTS.each do |element|
            gauges[:"passenger.process.#{i}.#{element}"]  = process[element.to_sym]
          end
        end

      end

    end
  end
end

