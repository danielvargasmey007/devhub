require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:action) }

    it 'validates action length maximum 50' do
      activity = build(:activity, action: 'a' * 51)
      expect(activity).not_to be_valid

      activity = build(:activity, action: 'a' * 50)
      expect(activity).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to polymorphic record' do
      task = create(:task)
      activity = create(:activity, record: task)

      expect(activity.record).to eq(task)
      expect(activity.record_type).to eq('Task')
    end

    it 'can belong to project' do
      project = create(:project)
      activity = create(:activity, :for_project)

      expect(activity.record).to be_a(Project)
    end

    it 'can belong to task' do
      activity = create(:activity, :for_task)
      expect(activity.record).to be_a(Task)
    end
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns activities in reverse chronological order' do
        activity1 = create(:activity)
        sleep(0.01)
        activity2 = create(:activity)
        sleep(0.01)
        activity3 = create(:activity)

        expect(Activity.recent.to_a).to eq([activity3, activity2, activity1])
      end

      it 'limits to 20 activities by default' do
        25.times { create(:activity) }
        expect(Activity.recent.count).to eq(20)
      end
    end

    describe '.for_record' do
      it 'returns activities for specific record' do
        task = create(:task)
        activity1 = create(:activity, record: task)
        activity2 = create(:activity, record: task)
        other_activity = create(:activity, record: create(:task))

        expect(Activity.for_record(task)).to match_array([activity1, activity2])
      end
    end
  end

  describe 'timestamps' do
    it 'has created_at but not updated_at' do
      activity = create(:activity)
      expect(activity).to respond_to(:created_at)
      expect(activity).not_to respond_to(:updated_at)
    end
  end

  describe 'factory traits' do
    it 'creates activity for task by default' do
      activity = create(:activity)
      expect(activity.record).to be_a(Task)
    end

    it 'creates activity for project with trait' do
      activity = create(:activity, :for_project)
      expect(activity.record).to be_a(Project)
    end
  end
end