require 'rails_helper'


RSpec.describe CruftTracker::ApplicationHelper, type: :request do
  # This helper method is tested via a request spec to avoid excessive mocking/stubbing. This is
  # more of an integration test, but it shows that the helper is working.
  describe '#record_cruft_tracker_view_render' do
    context 'when no errors occur' do
      it 'records metadata for the associated view' do
        view = CruftTracker::View.create(
          view: "app/views/numbers/show.html.erb"
        )

        expect do
          get number_path(123)
        end.to change { CruftTracker::ViewRender.count }.by(1)

        view_render = view.view_renders.first
        expect(view_render.controller).to eq('NumbersController')
        expect(view_render.endpoint).to eq('present')
        expect(view_render.route).to eq('/number/:index(.:format)')
        expect(view_render.render_stack).to be_a(Array)
      end

      context 'with metadata' do
        it 'records the metadata for the request' do
          view = CruftTracker::View.create(view: 'app/views/main/show.html.erb')
          partial = CruftTracker::View.create(view: 'app/views/shared/_whatever.html.erb')

          get main_path
          get main_path

          view.reload
          partial.reload
          expect(view.renders).to eq(2)
          expect(view.view_renders.count).to eq(1)
          expect(view.view_renders.first.occurrences).to eq(2)
          expect(view.view_renders.first.render_metadata.count).to eq(2)
          expect(view.view_renders.first.render_metadata.first.occurrences).to eq(1)
          expect(view.view_renders.first.render_metadata.second.occurrences).to eq(1)
          expect(partial.renders).to eq(2)
          expect(partial.view_renders.count).to eq(1)
          expect(partial.view_renders.first.occurrences).to eq(2)
          expect(partial.view_renders.first.render_metadata.count).to eq(1)
          expect(partial.view_renders.first.render_metadata.first.occurrences).to eq(2)
          expect(partial.view_renders.first.render_metadata.first.metadata).to eq("test"=>123)
        end
      end
    end

    context 'when a view record does not already exist' do
      it 'creates one' do
        expect do
          get number_path(123)
        end.to change { CruftTracker::View.count }.by(1).
          and(change  { CruftTracker::ViewRender.count }.by(1))
      end
    end

    context 'when an error occurs in tracking' do
      it 'is suppressed' do
        allow(CruftTracker::RecordViewRender).to receive(:run!).and_raise("💣KABOOOOOOOOM!💥")

        expect do
          get number_path(123)
        end.not_to raise_error
      end
    end
  end
end
