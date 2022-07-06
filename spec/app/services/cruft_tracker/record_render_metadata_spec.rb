require 'rails_helper'

RSpec.describe CruftTracker::RecordRenderMetadata do
  describe '#run!' do
    context 'with no metadata' do
      it 'does nothing' do
        view = CruftTracker::View.create(view: 'some/view.html.erb')
        view_render = CruftTracker::ViewRender.create(
          view: view,
          render_hash: '123',
          controller: 'SomeController',
          endpoint: 'some_endpoint',
          route: '/foo',
          http_method: 'POST',
          render_stack: []
        )

        expect do
          CruftTracker::RecordRenderMetadata.run!(
            view_render: view_render,
            metadata: nil
          )
        end.not_to change { CruftTracker::RenderMetadata.count }
      end
    end

    context 'with new metadata' do
      it 'creates new a metadata record' do
        view = CruftTracker::View.create(view: 'some/view.html.erb')
        view_render = CruftTracker::ViewRender.create(
          view: view,
          render_hash: '123',
          controller: 'SomeController',
          endpoint: 'some_endpoint',
          route: '/foo',
          http_method: 'DELETE',
          render_stack: []
        )

        expect do
          CruftTracker::RecordRenderMetadata.run!(
            view_render: view_render,
            metadata: { some: 'metadata' }
          )
        end.to change { CruftTracker::RenderMetadata.count }.by(1)
      end
    end

    context 'with existing metadata' do
      it 'increments the occurrences of the metadata' do
        view = CruftTracker::View.create(view: 'some/view.html.erb')
        view_render = CruftTracker::ViewRender.create(
          view: view,
          render_hash: '123',
          controller: 'SomeController',
          endpoint: 'some_endpoint',
          route: '/foo',
          http_method: 'PUT',
          render_stack: []
        )
        render_metadata = CruftTracker::RenderMetadata.create(
          view_render: view_render,
          metadata: { some: 'metadata' },
          metadata_hash: '631de6c2b97ff87eb40526dd6f11bc92',
          occurrences: 1
        )

        expect do
          CruftTracker::RecordRenderMetadata.run!(
            view_render: view_render,
            metadata: { some: 'metadata' }
          )

          render_metadata.reload
          expect(render_metadata.occurrences).to eq(2)
        end.not_to change { CruftTracker::RenderMetadata.count }
      end
    end
  end
end
