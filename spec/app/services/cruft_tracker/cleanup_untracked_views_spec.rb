require 'rails_helper'

RSpec.describe CruftTracker::CleanupUntrackedViews do
  describe '#run!' do
    it 'deletes view records for views that are no longer tracked' do
      untracked_view = CruftTracker::View.create(view: 'app/views/numbers/index.html.erb')
      tracked_view = CruftTracker::TrackView.run!(view: 'app/views/numbers/show.html.erb')

      CruftTracker::CleanupUntrackedViews.run!

      untracked_view.reload
      tracked_view.reload
      expect(untracked_view.deleted_at).not_to be_nil
      expect(tracked_view.deleted_at).to be_nil
    end
  end
end
