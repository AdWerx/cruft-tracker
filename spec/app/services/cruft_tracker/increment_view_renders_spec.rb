require 'rails_helper'

RSpec.describe CruftTracker::IncrementViewRenders do
  describe '#run!' do
    it 'records that a view was rendered' do
      view = CruftTracker::View.create(view: 'app/views/main/some_view.html.erb')

      CruftTracker::IncrementViewRenders.run!(view: view)

      view.reload

      expect(view.renders).to eq(1)
    end
  end
end
