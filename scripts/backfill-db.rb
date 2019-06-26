require 'date'
require 'pg'

DB_HOST           = ENV.fetch('DB_HOST', 'localhost')
DB_NAME           = ENV.fetch('DB_NAME', 'postgres')
DB_USER           = ENV.fetch('DB_USER', 'postgres')
DB_PASS           = ENV.fetch('DB_PASS', 'postgres')
MAX_REGISTRATIONS = ENV.fetch('MAX_REGISTRATIONS', '25').to_i
WORDS             = File.read('/usr/share/dict/words').lines.map(&:chomp)

connection = PG.connect(
  dbname: DB_NAME, host: DB_HOST, user: DB_USER, password: DB_PASS
)

(Date.new(2017, 8, 29)..Date.today).each do |step_date|
  days_registrations = rand(MAX_REGISTRATIONS)

  days_registrations.times do
    first_name = WORDS.sample.capitalize
    last_name  = WORDS.sample.capitalize

    query = <<~QUERY
      INSERT INTO registrations
        (first_name, last_name, created_at)
      VALUES ($1::text, $2::text, $3::timestamp)
    QUERY

    connection.exec_params(query, [first_name, last_name, step_date])
    puts "#{step_date} created #{first_name} #{last_name}"
  end
end
