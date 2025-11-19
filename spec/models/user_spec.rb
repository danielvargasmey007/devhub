require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    describe 'password validations' do
      it 'validates password confirmation matches' do
        user = build(:user, password: 'password123', password_confirmation: 'different')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it 'requires password confirmation when creating user' do
        user = User.new(name: 'Test', email: 'test@example.com')
        user.password = 'password123'
        # No password_confirmation set
        expect(user).not_to be_valid
      end

      it 'allows valid password with confirmation' do
        user = build(:user, password: 'password123', password_confirmation: 'password123')
        expect(user).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should have_many(:tasks).dependent(:nullify) }

    it 'allows tasks to be assigned to user' do
      user = create(:user)
      task = create(:task, assignee: user)

      expect(user.tasks).to include(task)
      expect(task.assignee).to eq(user)
    end

    it 'nullifies tasks when user is destroyed' do
      user = create(:user)
      task = create(:task, assignee: user)

      user.destroy
      task.reload

      expect(task.assignee).to be_nil
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }

    it 'saves encrypted password' do
      expect(user.crypted_password).to be_present
      expect(user.crypted_password).not_to eq('password123')
    end

    it 'generates password salt' do
      expect(user.password_salt).to be_present
    end

    it 'generates persistence token' do
      expect(user.persistence_token).to be_present
    end
  end

  describe '#admin?' do
    it 'returns false for regular users' do
      user = create(:user, admin: false)
      expect(user.admin?).to be false
    end

    it 'returns true for admin users' do
      admin = create(:user, :admin)
      expect(admin.admin?).to be true
    end
  end

  describe 'factory' do
    it 'creates valid user with factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates admin user with trait' do
      admin = create(:user, :admin)
      expect(admin.admin?).to be true
    end

    it 'creates user with tasks using trait' do
      user = create(:user, :with_tasks, tasks_count: 5)
      expect(user.tasks.count).to eq(5)
    end
  end

  describe 'email uniqueness' do
    it 'prevents duplicate emails (case insensitive)' do
      create(:user, email: 'test@example.com')
      duplicate = build(:user, email: 'TEST@example.com')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end

  describe 'timestamps' do
    it 'does not have timestamps (record_timestamps = false)' do
      user = create(:user)
      expect(user).not_to respond_to(:created_at)
      expect(user).not_to respond_to(:updated_at)
    end
  end
end