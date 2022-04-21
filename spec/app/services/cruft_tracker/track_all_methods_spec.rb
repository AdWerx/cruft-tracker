require 'rails_helper'

RSpec.describe(CruftTracker::TrackAllMethods) do
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

        CruftTracker::TrackAllMethods.run!(owner: ClassWithTaggedInstanceMethod)
      end
    end

    it 'creates method records for all methods in a class or module' do
      method_records =
        CruftTracker::TrackAllMethods.run!(owner: ClassThatIsTrackingAllMethods)

      expect(method_records.size).to eq(18)
    end
  end
end
