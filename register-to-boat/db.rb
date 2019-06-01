require 'date'

require 'active_record'

def setup_db_connection
  ActiveRecord::Base.establish_connection(
    adapter: :postgresql,
    host: ENV.fetch('DB_HOST', 'localhost'),
    database: ENV.fetch('DB_NAME', 'postgres'),
    username: ENV.fetch('DB_USERNAME', 'postgres'),
    password: ENV.fetch('DB_PASSWORD', 'postgres'),
  )
  ActiveRecord::Schema.define(version: 0) do
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end

def create_database(recreate: false)
  if !ActiveRecord::Base.connection.table_exists?('registrations') || recreate
    ActiveRecord::Schema.define(version: 0) do
      create_table 'registrations', id: :uuid, force: recreate do |t|
        t.string 'first_name'
        t.string 'last_name'

        t.boolean 'anonymous', default: false

        t.datetime 'created_at'
        t.datetime 'updated_at'
      end
    end
  end
end

class Registration < ActiveRecord::Base
  self.table_name = :registrations

  alias_attribute :guid, :id

  validates_each :first_name, :last_name do |record, attr, val|
    unless record.anonymous
      if val.nil?
        record.errors.add(attr, 'must be present')
      end

      unless !val.nil? && (2 <= val.length && val.length <= 64)
        record.errors.add(attr, 'must have length between 2 and 64')
      end
    end
  end
end
