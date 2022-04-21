require 'rails_helper'

RSpec.describe(CruftTracker::TrackMethod) do
  describe '#run!' do
    context 'when the cruft_tracker_methods table does not exist' do
      after do
        ActiveRecord::Base.connection.execute(
          'RENAME TABLE tmp_cruft_tracker_methods TO cruft_tracker_methods'
        )
      end

      it 'does not raise' do
        ActiveRecord::Base.connection.execute(
          'RENAME TABLE cruft_tracker_methods TO tmp_cruft_tracker_methods'
        )
        expect(Rails.logger).to receive(:warn)
          .with(
            'CruftTracker was unable to record a method. Does the cruft_tracker_methods table exist? Have migrations been run?'
          )
          .at_least(:once)

        CruftTracker::TrackMethod.run!(
          owner: ClassWithTaggedInstanceMethod,
          name: :some_instance_method
        )
      end
    end

    it 'creates a methods record for a tracked method' do
      expect do
        CruftTracker::TrackMethod.run!(
          owner: ClassWithTaggedInstanceMethod,
          name: :some_instance_method
        )
      end.to change { CruftTracker::Method.count }.by(1)
    end

    it 'registers a methods in the registry' do
      method_record =
        CruftTracker::TrackMethod.run!(
          owner: ClassWithTaggedInstanceMethod,
          name: :some_instance_method
        )

      expect(CruftTracker::Registry.include?(method_record)).to eq(true)
    end

    it 'wraps a tracked method so that invocations are recorded' do
      method_record =
        CruftTracker::TrackMethod.run!(
          owner: ClassWithTaggedInstanceMethod,
          name: :some_instance_method
        )

      ClassWithTaggedInstanceMethod.new.some_instance_method

      expect(method_record.reload.invocations).to eq(1)
    end
  end
end
