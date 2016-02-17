require 'mysql2_wrapper/version'
require 'mysql2'

module Mysql2Wrapper
  class Db
    def initialize(db_params)
      @connection = connect(db_params)
    end

    def to_s
      @connection.to_s
    end

    def connect(db_params)
      Mysql2::Client.new(db_params)
    end

    def connected?
      @connection.ping
    end

    def escape(string)
      @connection.escape(string)
    end

    def query(query, *values)
      @connection.prepare(query).execute(*values)
    end

    def get_one!(query, *values)
      results = query(query, *values)
      raise 'More than one result.' unless results.one?
      results.first
    end

    def get_one(query, *values)
      query(query, *values).first
    end

    def get_all(query, *values)
      query(query, *values).entries
    end

    def count(query, *values)
      count = query[/count\(.*\)/]&.to_sym
      raise ArgumentError, 'No count on the query.' if count.nil?
      get_one(query, *values)[count]
    end

    def transaction
      raise ArgumentError, 'No block was given' unless block_given?

      begin
        @connection.query('BEGIN')
        yield
        @connection.query('COMMIT')
      rescue StandardError => e
        warn e.message
        @connection.query('ROLLBACK')
        return nil
      end
    end

    def close
      @connection.close
    end
  end
end
