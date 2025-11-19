require 'rails_helper'

RSpec.describe Core::Projects::Updater do
  let(:project) { create(:project, name: 'Original Name', description: 'Original Description') }

  describe '#call' do
    context 'with valid parameters' do
      it 'updates project name' do
        updater = described_class.new(project, name: 'New Name')
        updater.call

        expect(project.reload.name).to eq('New Name')
      end

      it 'updates project description' do
        updater = described_class.new(project, description: 'New Description')
        updater.call

        expect(project.reload.description).to eq('New Description')
      end

      it 'returns true on success' do
        updater = described_class.new(project, name: 'New Name')
        expect(updater.call).to be true
      end

      it 'updates multiple attributes' do
        updater = described_class.new(project, name: 'New Name', description: 'New Description')
        updater.call

        project.reload
        expect(project.name).to eq('New Name')
        expect(project.description).to eq('New Description')
      end
    end

    context 'with invalid parameters' do
      it 'does not update with blank name' do
        updater = described_class.new(project, name: '')
        updater.call

        expect(project.reload.name).to eq('Original Name')
      end

      it 'returns false on failure' do
        updater = described_class.new(project, name: '')
        expect(updater.call).to be false
      end

      it 'sets errors on failure' do
        updater = described_class.new(project, name: '')
        updater.call

        expect(updater.errors).to be_present
      end
    end

    context 'with no parameters' do
      it 'returns true but makes no changes' do
        updater = described_class.new(project, {})
        expect(updater.call).to be true

        project.reload
        expect(project.name).to eq('Original Name')
        expect(project.description).to eq('Original Description')
      end
    end
  end
end