module Takwimu
  class Rack

    def initialize(app, reporter, options = {})
      @reporter = reporter
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @app = build_instrumented_app(app, @meters)
    end

    def call(env)
      env[TIMINGS] = {}
      env[GAUGES]  = []

      @app.call(env).tap { @reporter.report env }
    end
  end
end