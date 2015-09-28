require "mysql2"
require 'benchmark'

module Mysql2
  class Client
    module GeneralLog
      require "mysql2/client/general_log/version"

      class Log < Struct.new(
        :sql,
        :backtrace,
        :time,
      ); end

      attr_accessor :general_log

      def initialize(opts = {})
        @general_log = []
        super
      end

      # dependent on Mysql2::Client#query
      def query(sql, options={})
        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @general_log << Log.new(sql, caller_locations, time)
        ret
      end
    end

    prepend GeneralLog
  end
end
