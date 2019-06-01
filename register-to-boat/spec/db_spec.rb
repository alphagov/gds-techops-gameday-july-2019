describe 'Database' do

  before(:all) do
    setup_db_connection
  end

  before(:each) do
    create_database(recreate: true)
  end

  after(:all) do
    create_database(recreate: true)
  end

  context 'Registration' do
    context 'Not anonymous' do
      it 'needs attributes' do
        r = Registration.new
        expect(r.valid?).to be_falsey
      end

      it 'needs a first name' do
        r = Registration.new
        r.last_name = 'Lastname'
        expect(r.valid?).to be_falsey
      end

      it 'needs a long enough first name' do
        r = Registration.new
        r.first_name = 'a'
        r.last_name = 'Lastname'
        expect(r.valid?).to be_falsey
      end

      it 'needs a short enough first name' do
        r = Registration.new
        r.first_name = 'a' * 100
        r.last_name = 'Lastname'
        expect(r.valid?).to be_falsey
      end

      it 'needs a last name' do
        r = Registration.new
        r.first_name = 'Firstname'
        expect(r.valid?).to be_falsey
      end

      it 'needs a long enough last name' do
        r = Registration.new
        r.first_name = 'Firstname'
        r.last_name = 'a'
        expect(r.valid?).to be_falsey
      end

      it 'needs a short enough last name' do
        r = Registration.new
        r.first_name = 'Firstname'
        r.last_name = 'a' * 100
        expect(r.valid?).to be_falsey
      end

      it 'is valid when it has a first and last name' do
        r = Registration.new
        r.first_name = 'Firstname'
        r.last_name = 'Lastname'
        expect(r.valid?).to be_truthy
      end
    end

    context 'Anonymous' do
      it 'does not need a first name' do
        r = Registration.new
        r.anonymous = true
        r.last_name = 'Lastname'
        expect(r.valid?).to be_truthy
      end

      it 'does not need a last name' do
        r = Registration.new
        r.anonymous = true
        r.first_name = 'Firstname'
        expect(r.valid?).to be_truthy
      end

      it 'is valid when it lacks a first and last name' do
        r = Registration.new
        r.anonymous = true
        expect(r.valid?).to be_truthy
      end

      it 'a user can be made anonymous' do
        r = Registration.new
        r.first_name = 'Firstname'
        r.last_name = 'Lastname'

        expect(r.valid?).to be_truthy

        r.first_name = nil
        r.last_name = nil

        expect(r.valid?).to be_falsey

        r.anonymous = true

        expect(r.valid?).to be_truthy
      end
    end

    context 'Stats' do

      before { Timecop.freeze(Time.local(2019, 05, 15, 12, 0, 0)) }
      after  { Timecop.return }

      it 'can be computed' do
      expect(Registration.count).to eq(0)

      new_reg = -> (time) {
        r = Registration.new
        r.last_name  = 'Ever'
        r.first_name = 'Greatest'
        r.created_at = time
        r.save
      }

      2.times { new_reg.call(Time.new(0))                 }
      expect(Registration.count).to eq(2)

      2.times { new_reg.call(Time.now.beginning_of_year) }
      expect(Registration.registrations_this_year.count).to  eq(2)
      expect(Registration.count).to                          eq(4)

      2.times { new_reg.call(Time.now.beginning_of_month) }
      expect(Registration.registrations_this_month.count).to eq(2)
      expect(Registration.registrations_this_year.count).to  eq(4)
      expect(Registration.count).to                          eq(6)

      2.times { new_reg.call(Time.now.beginning_of_week) }
      expect(Registration.registrations_this_week.count).to  eq(2)
      expect(Registration.registrations_this_month.count).to eq(4)
      expect(Registration.registrations_this_year.count).to  eq(6)
      expect(Registration.count).to                          eq(8)

      2.times { new_reg.call(Time.now.beginning_of_day) }
      expect(Registration.registrations_today.count).to      eq(2)
      expect(Registration.registrations_this_week.count).to  eq(4)
      expect(Registration.registrations_this_month.count).to eq(6)
      expect(Registration.registrations_this_year.count).to  eq(8)
      expect(Registration.count).to                          eq(10)
      end
    end
  end
end
