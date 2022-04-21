require 'rails_helper'

RSpec.describe(CruftTracker::CleanupUntrackedMethods) do
  describe '#run!' do
    it 'deletes method records for classes or methods that are no longer tracked' do
      CruftTracker::Method.create(
        owner: 'ClassWithTaggedInstanceMethod',
        name: :some_missing_method_name,
        method_type: CruftTracker::Method::CLASS_METHOD
      )

      CruftTracker::Method.create(
        owner: 'SomeFakeClass',
        name: :some_fake_method_name,
        method_type: CruftTracker::Method::INSTANCE_METHOD
      )

      # This is a real class with a real method that is not actually tracked
      CruftTracker::Method.create(
        owner: 'ClassWithUntrackedMethod',
        name: :hello,
        method_type: CruftTracker::Method::INSTANCE_METHOD
      )

      # This is a real tracked class with a real tracked method (only this should survive cleanup)
      CruftTracker::Method.create(
        owner: 'ClassWithTaggedInstanceMethod',
        name: :some_instance_method,
        method_type: CruftTracker::Method::INSTANCE_METHOD
      )

      CruftTracker::CleanupUntrackedMethods.run!

      expect(CruftTracker::Method.where('deleted_at is not null').count).to eq(
        3
      )
    end
  end
end
