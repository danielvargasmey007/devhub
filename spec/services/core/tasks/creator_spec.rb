require 'rails_helper'

RSpec.describe Core::Tasks::Creator do
  let(:project) { create(:project) }

  describe '#call' do
    let(:valid_params) do
      {
        title: 'Test Task',
        description: 'Test Description',
        status: 'pending',
        project_id: project.id
      }
    end

    context 'with valid parameters' do
      it 'creates a task' do
        creator = described_class.new(project, valid_params)

        expect {
          creator.call
        }.to change(Task, :count).by(1)
      end

      it 'returns true on success' do
        creator = described_class.new(project, valid_params)
        expect(creator.call).to be true
      end

      it 'sets task attributes' do
        creator = described_class.new(project, valid_params)
        creator.call

        task = Task.last
        expect(task.title).to eq('Test Task')
        expect(task.description).to eq('Test Description')
        expect(task.status).to eq('pending')
        expect(task.project).to eq(project)
      end

      it 'allows task without description' do
        params = valid_params.except(:description)
        creator = described_class.new(project, params)

        expect(creator.call).to be true
        expect(Task.last.description).to be_nil
      end

      it 'assigns task to user if assignee_id provided' do
        user = create(:user)
        params = valid_params.merge(assignee_id: user.id, assignee_type: 'User')

        creator = described_class.new(project, params)
        creator.call

        task = Task.last
        expect(task.assignee).to eq(user)
      end

      it 'creates an activity log' do
        creator = described_class.new(project, valid_params)

        expect {
          creator.call
        }.to change(Activity, :count).by(1)
      end

      it 'creates activity with correct action' do
        creator = described_class.new(project, valid_params)
        creator.call

        activity = Activity.last
        expect(activity.action).to eq('created')
      end
    end

    context 'with invalid parameters' do
      it 'does not create task without title' do
        creator = described_class.new(project, valid_params.merge(title: nil))

        expect {
          creator.call
        }.not_to change(Task, :count)
      end

      it 'returns false on failure' do
        creator = described_class.new(project, valid_params.merge(title: nil))
        expect(creator.call).to be false
      end

      it 'sets errors on failure' do
        creator = described_class.new(project, valid_params.merge(title: nil))
        creator.call

        expect(creator.errors).to be_present
      end
    end

    context 'default values' do
      it 'defaults status to pending' do
        params = valid_params.except(:status)
        creator = described_class.new(project, params)
        creator.call

        expect(Task.last.status).to eq('pending')
      end
    end
  end
end