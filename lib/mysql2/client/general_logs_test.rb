require "mysql2/client/general_logs"

module Mysql2ClientGeneralLogsTest
  def test_main(m)
    @client = Mysql2::Client.new(
      host: "127.0.0.1",
      username: "root",
    )
    exit m.run
    @client.query("DROP DATABASE IF EXISTS `mysql2_client_general_logs_test`")
  end

  def db_init
    @client.query("DROP DATABASE IF EXISTS `mysql2_client_general_logs_test`")
    @client.query("CREATE DATABASE `mysql2_client_general_logs_test`")
    @client.query("USE `mysql2_client_general_logs_test`")
    @client.query(<<-SQL)
CREATE TABLE users (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL
);
SQL
    @client.query(<<-SQL)
INSERT INTO `users` (`name`, `password`)
       VALUES ('ksss', 'cheap-pass'),
              ('foo', 'fooo'),
              ('bar', 'barr')
;
SQL
    @client.general_logs.clear
  end

  def e(s)
    Mysql2::Client.escape(s)
  end

  def test_init(t)
    if !@client.general_logs.kind_of?(Array)
      t.error("initial value expect Array class got #{@client.general_logs.class}")
    end
    if !@client.general_logs.empty?
      t.error("initial value expect [] got #{@client.general_logs}")
    end
  end

  def test_values(t)
    db_init
    @client.query("SELECT * FROM users WHERE name = '#{e("ksss")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("barr")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("foo")}'")

    if @client.general_logs.length != 3
      t.error("expect log length 3 got #{@client.general_logs.length}")
    end
    if @client.general_logs.any?{|log| !log.kind_of?(Mysql2::Client::GeneralLogs::Log)}
      t.error("expect all collection item is instance of Mysql2::Client::GeneralLogs::Log got #{@client.general_logs.map(&:class).uniq}")
    end
  end

  def test_log_class(t)
    if Mysql2::Client::GeneralLogs::Log.members != [:sql, :backtrace, :time]
      t.error("expect Mysql2::Client::GeneralLogs::Log.members is [:sql, :backtrace, :time] got #{Mysql2::Client::GeneralLogs::Log.members}")
    end
  end

  def example_general_logs
    db_init
    @client.query("SELECT * FROM users WHERE name = '#{e("ksss")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("barr")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("foo")}'")
    puts @client.general_logs.map{|log| log.sql}
    puts @client.general_logs.map{|log| log.backtrace.find{|c| %r{/gems/} !~ c.to_s}.to_s.gsub(/.*?:/, '')}
    # Output:
    # SELECT * FROM users WHERE name = 'ksss'
    # SELECT * FROM users WHERE name = 'barr'
    # SELECT * FROM users WHERE name = 'foo'
    # in `example_general_logs'
    # in `example_general_logs'
    # in `example_general_logs'
  end
end
