require_relative '../db'

describe 'Database' do

  before(:all) do
    setup_db
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
  end
end
