require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:tasks).dependent(:destroy) }

    it 'destroys associated tasks when project is destroyed' do
      project = create(:project)
      task1 = create(:task, project: project)
      task2 = create(:task, project: project)

      expect {
        project.destroy
      }.to change(Task, :count).by(-2)
    end
  end

  describe 'factory' do
    it 'creates valid project' do
      project = build(:project)
      expect(project).to be_valid
    end

    it 'creates project with tasks using trait' do
      project = create(:project, :with_tasks, tasks_count: 3)
      expect(project.tasks.count).to eq(3)
    end
  end

  describe 'timestamps' do
    it 'does not have timestamps' do
      project = create(:project)
      expect(project).not_to respond_to(:created_at)
      expect(project).not_to respond_to(:updated_at)
    end
  end
end