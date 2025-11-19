require 'rails_helper'

RSpec.describe Core::Tasks::Updater do
  let(:task) { create(:task, title: 'Original Title', description: 'Original Description') }

  describe '#call' do
    context 'with valid parameters' do
      it 'updates task title' do
        updater = described_class.new(task, title: 'New Title')
        updater.call

        expect(task.reload.title).to eq('New Title')
      end

      it 'updates task description' do
        updater = described_class.new(task, description: 'New Description')
        updater.call

        expect(task.reload.description).to eq('New Description')
      end

      it 'updates task assignee' do
        user = create(:user)
        updater = described_class.new(task, assignee_id: user.id, assignee_type: 'User')
        updater.call

        expect(task.reload.assignee).to eq(user)
      end

      it 'returns true on success' do
        updater = described_class.new(task, title: 'New Title')
        expect(updater.call).to be true
      end

      it 'updates multiple attributes' do
        updater = described_class.new(task, title: 'New Title', description: 'New Description')
        updater.call

        task.reload
        expect(task.title).to eq('New Title')
        expect(task.description).to eq('New Description')
      end
    end

    context 'with invalid parameters' do
      it 'does not update with blank title' do
        updater = described_class.new(task, title: '')
        updater.call

        expect(task.reload.title).to eq('Original Title')
      end

      it 'returns false on failure' do
        updater = described_class.new(task, title: '')
        expect(updater.call).to be false
      end

      it 'sets errors on failure' do
        updater = described_class.new(task, title: '')
        updater.call

        expect(updater.errors).to be_present
      end
    end

    context 'status updates' do
      it 'allows status updates through params' do
        updater = described_class.new(task, status: 'completed')
        updater.call

        # Service doesn't prevent status updates (use StatusUpdater for business logic)
        expect(task.reload.status).to eq('completed')
      end
    end
  end
end