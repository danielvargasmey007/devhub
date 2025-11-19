require 'rails_helper'

RSpec.describe Core::Tasks::StatusUpdater do
  let(:task) { create(:task, status: :pending) }

  describe '#call' do
    context 'with valid status' do
      it 'updates task status' do
        updater = described_class.new(task, 'in_progress')
        updater.call

        expect(task.reload.status).to eq('in_progress')
      end

      it 'returns true on success' do
        updater = described_class.new(task, 'completed')
        expect(updater.call).to be true
      end

      it 'enqueues ActivityLoggerJob' do
        updater = described_class.new(task, 'completed')

        expect {
          updater.call
        }.to have_enqueued_job(ActivityLoggerJob).with(task.id, 'pending', 'completed')
      end

      it 'handles symbol status' do
        updater = described_class.new(task, :completed)
        updater.call

        expect(task.reload.status).to eq('completed')
      end
    end

    context 'with invalid status' do
      it 'returns false with invalid status' do
        updater = described_class.new(task, 'invalid_status')
        expect(updater.call).to be false
      end

      it 'does not update status with invalid value' do
        updater = described_class.new(task, 'invalid_status')
        updater.call

        expect(task.reload.status).to eq('pending')
      end

      it 'sets errors on failure' do
        updater = described_class.new(task, 'invalid_status')
        updater.call

        expect(updater.errors).to be_present
      end

      it 'does not enqueue job on failure' do
        updater = described_class.new(task, 'invalid_status')

        expect {
          updater.call
        }.not_to have_enqueued_job(ActivityLoggerJob)
      end
    end

    context 'status transitions' do
      it 'allows transition from pending to in_progress' do
        updater = described_class.new(task, 'in_progress')
        expect(updater.call).to be true
      end

      it 'allows transition from in_progress to completed' do
        task.update(status: :in_progress)
        updater = described_class.new(task, 'completed')
        expect(updater.call).to be true
      end

      it 'allows transition from completed to archived' do
        task.update(status: :completed)
        updater = described_class.new(task, 'archived')
        expect(updater.call).to be true
      end

      it 'allows any status to be set' do
        task.update(status: :archived)
        updater = described_class.new(task, 'pending')
        expect(updater.call).to be true
      end
    end
  end
end