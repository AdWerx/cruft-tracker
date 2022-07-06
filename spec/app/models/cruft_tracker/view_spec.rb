require 'rails_helper'

RSpec.describe CruftTracker::View do
  describe '#still_exists?' do
    it 'returns false for a view that does not exist' do
      expect(
        CruftTracker::View.new(view: 'app/views/numbers/foo.html.erb').still_exists?
      ).to eq(false)
    end

    it 'returns true for a view that exists' do
      expect(
        CruftTracker::View.new(view: 'app/views/numbers/index.html.erb').still_exists?
      ).to eq(true)
    end
  end

  describe '#still_tracked?' do
    it 'returns false when a tracked view does not exist in the registry' do
      view = CruftTracker::View.new(view: 'app/views/numbers/index.html.erb')

      expect(view.still_tracked?).to eq(false)
    end

    it 'returns true when a tracked view does exist in the registry' do
      view = CruftTracker::View.new(view: 'app/views/numbers/index.html.erb')

      CruftTracker::Registry << view

      expect(view.still_tracked?).to eq(true)
    end

    it 'returns true if the view file contains "record_cruft_tracker_view_render"' do
      view = CruftTracker::View.new(view: 'app/views/numbers/show.html.erb')

      expect(view.still_tracked?).to eq(true)
    end
  end
end
