require 'rails_helper'

RSpec.describe(CruftTracker::RecordInvocation) do
  describe '#run!' do
    it 'increments invocations on a method record' do
      method =
        CruftTracker::Method.create(
          owner: 'ClassWithTaggedInstanceMethod',
          name: :some_instance_method,
          method_type: CruftTracker::Method::INSTANCE_METHOD,
          updated_at: 5.days.ago
        )

      CruftTracker::RecordInvocation.run!(method: method)
      CruftTracker::RecordInvocation.run!(method: method)

      method.reload

      expect(method.invocations).to eq(2)
      expect(method.updated_at).to be_within(5.seconds).of(DateTime.current)
    end
  end
end
