require 'rails_helper'

RSpec.describe(CruftTracker::Registry) do
  it 'is a singleton' do
    expect { CruftTracker::Registry.new }.to raise_error(NoMethodError)
  end

  describe '#<<' do
    it 'can register methods being tracked' do
      method = CruftTracker::Method.new

      CruftTracker::Registry.instance << method

      expect(CruftTracker::Registry.instance.tracked_methods).to eq([method])
    end
  end

  describe '#include?' do
    it 'indicates if a method is included in the registry' do
      method =
        CruftTracker::Method.new(
          owner: 'ClassWithUntrackedMethod',
          name: 'hello',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      CruftTracker::Registry.instance << method

      expect(CruftTracker::Registry.instance.include?(method)).to eq(true)
    end
  end
end
