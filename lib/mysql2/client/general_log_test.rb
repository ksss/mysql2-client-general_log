require "mysql2/client/general_log"

module Mysql2ClientGeneralLogTest
  def test_main(m)
    @client = Mysql2::Client.new(
      host: "127.0.0.1",
      username: "root",
    )
    exit m.run
    @client.query("DROP DATABASE IF EXISTS `mysql2_client_general_log_test`")
  end

  def db_init
    @client.query("DROP DATABASE IF EXISTS `mysql2_client_general_log_test`")
    @client.query("CREATE DATABASE `mysql2_client_general_log_test`")
    @client.query("USE `mysql2_client_general_log_test`")
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
    @client.general_log.clear
  end

  def e(s)
    Mysql2::Client.escape(s)
  end

  def test_init(t)
    if !@client.general_log.kind_of?(Array)
      t.error("initial value expect Array class got #{@client.general_log.class}")
    end
    if !@client.general_log.empty?
      t.error("initial value expect [] got #{@client.general_log}")
    end
  end

  def test_values(t)
    db_init
    ret = @client.query("SELECT * FROM users WHERE name = '#{e("ksss")}'").first
    @client.query("SELECT * FROM users WHERE name = '#{e("barr")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("foo")}'")

    if @client.general_log.length != 3
      t.error("expect log length 3 got #{@client.general_log.length}")
    end
    if @client.general_log.any?{|log| !log.kind_of?(Mysql2::Client::GeneralLog::Log)}
      t.error("expect all collection item is instance of Mysql2::Client::GeneralLog::Log got #{@client.general_log.map(&:class).uniq}")
    end
    expect = {"id"=>1, "name"=>"ksss", "password"=>"cheap-pass"}
    if ret != expect
      t.error("expect query output not change from #{expect} got #{ret}")
    end
  end

  def test_log_class(t)
    if Mysql2::Client::GeneralLog::Log.members != [:sql, :backtrace, :time]
      t.error("expect Mysql2::Client::GeneralLog::Log.members is [:sql, :backtrace, :time] got #{Mysql2::Client::GeneralLog::Log.members}")
    end
  end

  def example_general_log
    db_init
    @client.query("SELECT * FROM users WHERE name = '#{e("ksss")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("barr")}'")
    @client.query("SELECT * FROM users WHERE name = '#{e("foo")}'")
    puts @client.general_log.map{|log| log.sql}
    puts @client.general_log.map{|log| log.backtrace.find{|c| %r{/gems/} !~ c.to_s}.to_s.gsub(/.*?:/, '')}
    # Output:
    # SELECT * FROM users WHERE name = 'ksss'
    # SELECT * FROM users WHERE name = 'barr'
    # SELECT * FROM users WHERE name = 'foo'
    # in `example_general_log'
    # in `example_general_log'
    # in `example_general_log'
  end
end
