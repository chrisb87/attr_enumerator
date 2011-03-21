$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'active_record'
require 'attr_enumerator'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

class ActiveRecordModel < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3',
                       :database => ':memory:'

  connection.execute <<-EOS
    CREATE TABLE #{table_name} (
      #{primary_key} integer PRIMARY KEY AUTOINCREMENT
    )
  EOS
end
