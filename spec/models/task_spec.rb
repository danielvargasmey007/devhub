require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }

    it 'validates title length maximum 255' do
      task = build(:task, title: 'a' * 256)
      expect(task).not_to be_valid

      task = build(:task, title: 'a' * 255)
      expect(task).to be_valid
    end

    it 'validates description length maximum 5000' do
      task = build(:task, description: 'a' * 5001)
      expect(task).not_to be_valid

      task = build(:task, description: 'a' * 5000)
      expect(task).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:project) }

    it 'allows polymorphic assignee' do
      user = create(:user)
      task = create(:task, assignee: user)

      expect(task.assignee).to eq(user)
      expect(task.assignee_type).to eq('User')
    end

    it 'allows task without assignee' do
      task = create(:task, assignee: nil)
      expect(task).to be_valid
      expect(task.assignee).to be_nil
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Task.statuses).to eq({
        'pending' => 'pending',
        'in_progress' => 'in_progress',
        'completed' => 'completed',
        'archived' => 'archived'
      })
    end

    it 'allows status to be set' do
      task = create(:task, status: :pending)
      expect(task.status).to eq('pending')

      task.update(status: :completed)
      expect(task.status).to eq('completed')
    end
  end

  describe 'scopes' do
    describe '.completed' do
      it 'returns only completed tasks' do
        completed1 = create(:task, :completed)
        completed2 = create(:task, :completed)
        pending = create(:task, :pending)

        expect(Task.completed).to match_array([completed1, completed2])
      end
    end

    describe '.assigned_to' do
      it 'returns tasks assigned to specific user' do
        user = create(:user)
        task1 = create(:task, assignee: user)
        task2 = create(:task, assignee: user)
        task3 = create(:task, assignee: create(:user))

        expect(Task.assigned_to(user)).to match_array([task1, task2])
      end
    end
  end

  describe 'factory traits' do
    it 'creates pending task' do
      task = create(:task, :pending)
      expect(task.status).to eq('pending')
    end

    it 'creates in_progress task' do
      task = create(:task, :in_progress)
      expect(task.status).to eq('in_progress')
    end

    it 'creates completed task' do
      task = create(:task, :completed)
      expect(task.status).to eq('completed')
    end

    it 'creates task with assignee' do
      task = create(:task, :with_assignee)
      expect(task.assignee).to be_a(User)
    end
  end

  describe 'timestamps' do
    it 'does not have timestamps' do
      task = create(:task)
      expect(task).not_to respond_to(:created_at)
      expect(task).not_to respond_to(:updated_at)
    end
  end
end