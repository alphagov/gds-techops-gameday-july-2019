require_relative '../db'

describe 'Database' do

  before(:all) do
    setup_db
  end

  context 'Registration' do
    it 'needs attributes' do
      r = Registration.new
      expect(r.valid?).to be_falsey
    end

    it 'needs a first name' do
      r = Registration.new
      r.last_name = 'Lastname'
      expect(r.valid?).to be_falsey
    end

    it 'needs a last name' do
      r = Registration.new
      r.first_name = 'Firstname'
      expect(r.valid?).to be_falsey
    end

    it 'is valid when it has a first and last name' do
      r = Registration.new
      r.first_name = 'Firstname'
      r.last_name = 'Lastname'
      expect(r.valid?).to be_truthy
    end
  end
end
