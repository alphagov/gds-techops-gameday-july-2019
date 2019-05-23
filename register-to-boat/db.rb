require 'active_record'

def setup_db
  ActiveRecord::Base.establish_connection(
    adapter: :postgresql,
    host: ENV.fetch('DB_HOST', 'localhost'),
    database: ENV.fetch('DB_NAME', 'postgres'),
    username: ENV.fetch('DB_USERNAME', 'postgres'),
    password: ENV.fetch('DB_PASSWORD', 'postgres'),
  )

  ActiveRecord::Schema.define(version: 0) do
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table 'registrations', id: :uuid, force: true do |t|
      t.string 'first_name'
      t.string 'last_name'

      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end

class Registration < ActiveRecord::Base
  self.table_name = :registrations

  alias_attribute :guid, :id

  validates :first_name, presence: true, length: { minimum: 2, maximum: 64 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 64 }
end
