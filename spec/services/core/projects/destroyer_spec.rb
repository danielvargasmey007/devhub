require 'rails_helper'

RSpec.describe Core::Projects::Destroyer do
  let(:project) { create(:project) }

  describe '#call' do
    it 'destroys the project' do
      project # Create the project
      destroyer = described_class.new(project)

      expect {
        destroyer.call
      }.to change(Project, :count).by(-1)
    end

    it 'returns true on success' do
      destroyer = described_class.new(project)
      expect(destroyer.call).to be true
    end

    it 'destroys associated tasks' do
      task1 = create(:task, project: project)
      task2 = create(:task, project: project)

      destroyer = described_class.new(project)

      expect {
        destroyer.call
      }.to change(Task, :count).by(-2)
    end

    context 'when project has many tasks' do
      it 'destroys all associated tasks' do
        create_list(:task, 10, project: project)

        destroyer = described_class.new(project)

        expect {
          destroyer.call
        }.to change(Task, :count).by(-10)
      end
    end

    context 'when destruction fails' do
      before do
        allow(project).to receive(:destroy!).and_raise(ActiveRecord::RecordInvalid.new(project))
      end

      it 'returns false' do
        destroyer = described_class.new(project)
        expect(destroyer.call).to be false
      end

      it 'sets errors' do
        destroyer = described_class.new(project)
        destroyer.call

        expect(destroyer.errors).to be_present
      end
    end
  end
end