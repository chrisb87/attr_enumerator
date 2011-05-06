require 'active_record'
require 'attr_enumerator'

class ActiveRecordModel < ActiveRecord::Base
  establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  connection.execute("CREATE TABLE #{table_name} (#{primary_key} integer PRIMARY KEY AUTOINCREMENT)")
end
