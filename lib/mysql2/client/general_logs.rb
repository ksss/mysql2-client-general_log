require "mysql2"
require 'benchmark'

module Mysql2
  class Client
    module GeneralLogs
      require "mysql2/client/general_logs/version"

      class Log < Struct.new(
        :sql,
        :backtrace,
        :time,
      ); end

      attr_accessor :general_logs

      def initialize(opts = {})
        @general_logs = []
        super
      end

      # dependent on Mysql2::Client#query
      def query(sql, options={})
        time = Benchmark.realtime do
          super
        end
        @general_logs << Log.new(sql, caller_locations, time)
      end
    end

    prepend GeneralLogs
  end
end
