require 'rails_helper'

RSpec.describe(CruftTracker::InitiateViewTracking) do
  describe '#run!' do
    it 'creates view records for tracked views that do not already have a view record' do
      expect do
        CruftTracker::InitiateViewTracking.run!(pathnames: ActionController::Base.view_paths)
      end.to change { CruftTracker::View.count }.by(1)
    end
  end
end
