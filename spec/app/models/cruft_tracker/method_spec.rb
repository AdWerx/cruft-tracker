require 'rails_helper'

RSpec.describe(CruftTracker::Method) do
  describe '#still_exists?' do
    it 'returns false for a class that does not exist' do
      expect(
        CruftTracker::Method.new(owner: 'SomeFakeClass').still_exists?
      ).to eq(false)
    end

    it 'returns false for a method that does not exist on a class' do
      expect(
        CruftTracker::Method.new(
          owner: 'ClassWithTaggedInstanceMethod',
          name: 'some_missing_method_name',
          method_type: CruftTracker::Method::CLASS_METHOD
        ).still_exists?
      ).to eq(false)
    end

    it 'returns true with the tracked class and method still exist' do
      expect(
        CruftTracker::Method.new(
          owner: 'ClassWithTaggedInstanceMethod',
          name: 'some_instance_method',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        ).still_exists?
      ).to eq(true)
    end
  end

  describe '#still_tracked?' do
    it 'returns false when the tracked method does not appear in the registry' do
      method =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      expect(CruftTracker::Registry.include?(method)).to eq(false)
    end

    it 'returns true when the tracked method is in the registry' do
      method =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      CruftTracker::Registry << method

      expect(CruftTracker::Registry.include?(method)).to eq(true)
    end
  end

  describe '#==' do
    it 'is false if the owner, name, and method type are not all the same' do
      method1 =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )
      method2 =
        CruftTracker::Method.new(
          owner: 'ClassWithTaggedInstanceMethod',
          name: 'some_instance_method',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      expect(method1 == method2).to eq(false)
    end

    it 'is true when the owner, name, and method type are all the same' do
      method1 =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )
      method2 =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      expect(method1 == method2).to eq(true)
    end
  end
end
