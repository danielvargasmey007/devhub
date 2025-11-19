require 'rails_helper'

RSpec.describe Core::Projects::Creator do
  describe '#call' do
    let(:valid_params) do
      {
        name: 'Test Project',
        description: 'Test Description'
      }
    end

    context 'with valid parameters' do
      it 'creates a project' do
        creator = described_class.new(valid_params)

        expect {
          creator.call
        }.to change(Project, :count).by(1)
      end

      it 'returns true on success' do
        creator = described_class.new(valid_params)
        expect(creator.call).to be true
      end

      it 'sets the project name' do
        creator = described_class.new(valid_params)
        creator.call

        project = Project.last
        expect(project.name).to eq('Test Project')
      end

      it 'sets the project description' do
        creator = described_class.new(valid_params)
        creator.call

        project = Project.last
        expect(project.description).to eq('Test Description')
      end

      it 'creates an activity log' do
        creator = described_class.new(valid_params)

        expect {
          creator.call
        }.to change(Activity, :count).by(1)
      end

      it 'creates activity with correct action' do
        creator = described_class.new(valid_params)
        creator.call

        activity = Activity.last
        expect(activity.action).to eq('created')
      end

      it 'links activity to the created project' do
        creator = described_class.new(valid_params)
        creator.call

        project = Project.last
        activity = Activity.last
        expect(activity.record).to eq(project)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a project without a name' do
        creator = described_class.new(name: nil, description: 'Test')

        expect {
          creator.call
        }.not_to change(Project, :count)
      end

      it 'returns false on failure' do
        creator = described_class.new(name: nil)
        expect(creator.call).to be false
      end

      it 'sets errors on failure' do
        creator = described_class.new(name: nil)
        creator.call

        expect(creator.errors).to be_present
      end

      it 'does not create activity on failure' do
        creator = described_class.new(name: nil)

        expect {
          creator.call
        }.not_to change(Activity, :count)
      end
    end

    context 'edge cases' do
      it 'handles empty description' do
        creator = described_class.new(name: 'Test Project', description: '')
        expect(creator.call).to be true
      end

      it 'handles nil description' do
        creator = described_class.new(name: 'Test Project', description: nil)
        expect(creator.call).to be true
      end
    end
  end
end