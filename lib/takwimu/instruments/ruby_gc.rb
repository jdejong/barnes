# A note on GAUGE_COUNTERS.
#
# The sample_rate argument allows for the parameterization
# of instruments that decide to report data as gauges, that
# would typically be reported as counters.
#
# Aggregating counters is typically done simply with the `+`
# operator, which doesn't preserve the number of unique
# reporters that contributed to the count, or allow for one
# to learn the *average* of the counts posted.
#
# A gauge is typically aggregated by simply *replacing* the
# previous value, however, some systems do *more* with gauges
# when aggregating across multiple sources of that gauge, like,
# average, or compute stdev.
#
# This is problematic, however, when a gauge is being used as
# a counter, to preserve the average / stdev computational
# properties from above, because the interval that the gauge
# is being read it, affects the derivative of the increasing
# count. Instead of the derivative over 60s, the derivative is
# taken every 10s, giving us a derivative value that's approximately
# 1/6th of the actual derivative over 60s.
#
# We compensate for this by allowing Instruments to correct for
# this, and ensure that, even though it's an estimate, the data
# is scaled appropriately to the target aggregation interval, not
# just the collection interval.

module Takwimu
  module Instruments
    class RubyGC
      COUNTERS = {
        :count => :'GC.count',
        :major_gc_count => :'GC.major_count',
        :minor_gc_count => :'GC.minor_gc_count',
        :heap_allocated_pages => :'GC.heap_allocated_pages',
        :heap_sorted_length => :'GC.heap_sorted_length',
        :heap_allocatable_pages => :'GC.heap_allocatable_pages',
        :heap_available_slots => :'GC.heap_available_slots',
        :heap_live_slots => :'GC.heap_live_slots',
        :heap_free_slots => :'GC.heap_free_slots',
        :heap_final_slots => :'GC.heap_final_slots',
        :heap_marked_slots => :'GC.heap_marked_slots',
        :heap_swept_slots => :'GC.heap_swept_slots',
        :heap_eden_pages => :'GC.heap_eden_pages',
        :heap_tomb_pages => :'GC.heap_tomb_pages',
        :total_allocated_pages => :'GC.total_allocated_pages',
        :total_freed_pages => :'GC.total_freed_pages',
        :total_allocated_objects => :'GC.total_allocated_objects',
        :total_freed_objects => :'GC.total_freed_objects',
        :malloc_increase_bytes => :'GC.malloc_increase_bytes',
        :malloc_increase_bytes_limit => :'GC.malloc_increase_bytes_limit',
        :remembered_wb_unprotected_objects => :'GC.remembered_wb_unprotected_objects',
        :remembered_wb_unprotected_objects_limit => :'GC.remembered_wb_unprotected_objects_limit',
        :old_objects => :'GC.old_objects',
        :old_objects_limit => :'GC.old_objects_limit',
        :oldmalloc_increase_bytes => :'GC.oldmalloc_increase_bytes',
        :oldmalloc_increase_bytes_limit => :'GC.oldmalloc_increase_bytes_limit'
      }

      GAUGE_COUNTERS = {}

      # Detect Ruby 2.1 vs 2.2 GC.stat naming
      begin
        GC.stat :total_allocated_objects
      rescue ArgumentError
        GAUGE_COUNTERS.update \
          :total_allocated_object => :'GC.total_allocated_objects',
          :total_freed_object => :'GC.total_freed_objects'
      else
        GAUGE_COUNTERS.update \
          :total_allocated_objects => :'GC.total_allocated_objects',
          :total_freed_objects => :'GC.total_freed_objects'
      end

      def initialize(sample_rate)
        # see header for an explanation of how this sample_rate is used
        @sample_rate = sample_rate
      end

      def start!(state)
        state[:ruby_gc] = GC.stat
      end

      def instrument!(state, counters, gauges, timers)
        last = state[:ruby_gc]
        cur = state[:ruby_gc] = GC.stat

        COUNTERS.each do |stat, metric|
          counters[metric] = cur[stat] - last[stat] if cur.include? stat
        end

        # special treatment gauges
        GAUGE_COUNTERS.each do |stat, metric|
          if cur.include? stat
            val = cur[stat] - last[stat] if cur.include? stat
            gauges[metric] = val * (1/@sample_rate)
          end
        end

        # the rest of the gauges
        cur.each do |k, v|
          unless GAUGE_COUNTERS.include? k
            gauges[:"GC.#{k}"] = v
          end
        end
      end
    end
  end
end
