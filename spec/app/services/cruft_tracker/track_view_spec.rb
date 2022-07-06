require 'rails_helper'

RSpec.describe CruftTracker::TrackView do
  describe '#run!' do
    context 'without an existing view record' do
      it 'creates a view record and configures a render subscription' do
        expect(ActiveSupport::Notifications).to receive(:subscribe).with(
          instance_of(Regexp)
        )

        expect do
          CruftTracker::TrackView.run!(view: 'some/view.html.erb')
        end.to change { CruftTracker::View.count }.by(1)
      end
    end

    context 'with an existing view record' do
      it 'configures a render subscription' do
        CruftTracker::View.create(view: 'some/view.html.erb')
        expect(ActiveSupport::Notifications).to receive(:subscribe).with(
          instance_of(Regexp)
        )

        expect do
          CruftTracker::TrackView.run!(view: 'some/view.html.erb')
        end.not_to change { CruftTracker::View.count }
      end
    end

    context 'when the view record has been deleted' do
      it 'undeletes the view record' do
        view =
          CruftTracker::View.create(
            view: 'some/view.html.erb',
            deleted_at: Time.current
          )
        expect(ActiveSupport::Notifications).to receive(:subscribe).with(
          instance_of(Regexp)
        )

        CruftTracker::TrackView.run!(view: 'some/view.html.erb')

        view.reload
        expect(view.deleted_at).to be_nil
      end
    end
  end
end
