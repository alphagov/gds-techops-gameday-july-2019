describe 'Web' do

  before(:all) do
    setup_db_connection
  end

  before(:each) do
    create_database(recreate: true)
  end

  after(:all) do
    create_database(recreate: true)
  end

  context 'Home' do
    it 'works' do
      get '/'

      expect(last_response.ok?).to be_truthy
      expect(last_response.body).to include('TECH.OPS')
      expect(last_response.body).to include('Register')
      expect(last_response.body).to include('Stats')
    end
  end

  context 'Registration' do
    it 'shows a form' do
      get '/register'

      expect(last_response.ok?).to be_truthy
      expect(last_response.body).to include('First name')
      expect(last_response.body).to include('Last name')
      expect(last_response.body.lines.grep(/<input/).length).to eq(2)
      expect(last_response.body.lines.grep(/<button/).length).to eq(2)
    end

    context 'Success' do
      it 'mocks the IT industry and shows the registration guid' do
        expect(Registration.count).to eq(0)
        post '/register', { last_name: 'Ever', first_name: 'Greatest' }
        expect(last_response.body).to include(
          'Your personal data has been securely stored in a public s3 bucket.'
        )
        expect(Registration.count).to eq(1)

        registration = Registration.first
        expect(last_response.body).to include('Your reference number')
        expect(last_response.body).to include(registration.guid)

      end
    end

    context 'No user data' do
      it 'mocks the user and shows helpful error messages' do
        post '/register'

        expect(last_response.body).to include('You are bad')

        expect(last_response.body).to include(
          'First name must have length between 2 and 64'
        )
        expect(last_response.body).to include(
          'Last name must have length between 2 and 64'
        )
      end
    end
  end

  context 'Stats' do
    it 'renders a table' do
      new_reg = -> (time) {
        r = Registration.new
        r.last_name  = 'Ever'
        r.first_name = 'Greatest'
        r.created_at = time
        r.save
      }

      beginning_registrations   = 25
      registrations_start_year  = 20
      registrations_start_month = 15
      registrations_start_week  = 10
      registrations_today       = 5

      beginning_registrations.times   { new_reg.call(Time.new(0))                 }
      registrations_start_year.times  { new_reg.call(Time.now.beginning_of_year)  }
      registrations_start_month.times { new_reg.call(Time.now.beginning_of_month) }
      registrations_start_week.times  { new_reg.call(Time.now.beginning_of_week)  }
      registrations_today.times       { new_reg.call(Time.now.beginning_of_day)   }

      get '/stats'

      expect(last_response.ok?).to be_truthy

      expect(last_response.body).to match(
        /Today[^\n]*\n[^\n]*#{Registration.registrations_today.count}/
      )

      expect(last_response.body).to match(
        /This week[^\n]*\n[^\n]*#{Registration.registrations_this_week.count}/
      )

      expect(last_response.body).to match(
        /This month[^\n]*\n[^\n]*#{Registration.registrations_this_month.count}/
      )

      expect(last_response.body).to match(
        /This year[^\n]*\n[^\n]*#{Registration.registrations_this_year.count}/
      )

      expect(last_response.body).to match(
        /All time[^\n]*\n[^\n]*#{Registration.count}/
      )
    end
  end
end
