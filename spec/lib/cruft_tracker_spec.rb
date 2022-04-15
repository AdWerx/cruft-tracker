require 'rails_helper'

RSpec.describe(CruftTracker) do
  describe '.is_this_method_used?' do
    it 'overrides methods on classes that tag methods with is_this_method_used?' do
      expect do
        load './spec/dummy/app/models/class_with_tagged_instance_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      ClassWithTaggedInstanceMethod.new.some_instance_method
      ClassWithTaggedInstanceMethod.new.some_instance_method

      expect(CruftTracker::Method.count).to eq(1)
      method = CruftTracker::Method.first

      # TODO: consider renaming these to "owner", "name", and "type". Maybe
      expect(method.owner_name).to eq('ClassWithTaggedInstanceMethod')
      expect(method.method_name).to eq('some_instance_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::INSTANCE_METHOD.to_s
      )
      expect(method.invocations).to eq(2)
      expect(method.deleted_at).to eq(nil)
    end

    it 'overrides methods on modules that tag methods with is_this_method_used?' do
      fail
    end

    it 'overrides instance methods' do
      fail
    end

    it 'overrides class methods' do
      fail
    end

    it 'allows the user to disambiguate between class and instance methods with the same name' do
      fail
    end
  end
end
