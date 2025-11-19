require 'rails_helper'

RSpec.describe Core::Tasks::Destroyer do
  let(:task) { create(:task) }

  describe '#call' do
    it 'destroys the task' do
      task # Create the task
      destroyer = described_class.new(task)

      expect {
        destroyer.call
      }.to change(Task, :count).by(-1)
    end

    it 'returns true on success' do
      destroyer = described_class.new(task)
      expect(destroyer.call).to be true
    end

    context 'when task has assignee' do
      it 'destroys task but keeps user' do
        user = create(:user)
        task = create(:task, assignee: user)

        destroyer = described_class.new(task)

        expect {
          destroyer.call
        }.to change(Task, :count).by(-1).and change(User, :count).by(0)

        expect(User.exists?(user.id)).to be true
      end
    end

    context 'when destruction fails' do
      before do
        allow(task).to receive(:destroy!).and_raise(ActiveRecord::RecordInvalid.new(task))
      end

      it 'returns false' do
        destroyer = described_class.new(task)
        expect(destroyer.call).to be false
      end

      it 'sets errors' do
        destroyer = described_class.new(task)
        destroyer.call

        expect(destroyer.errors).to be_present
      end
    end
  end
end