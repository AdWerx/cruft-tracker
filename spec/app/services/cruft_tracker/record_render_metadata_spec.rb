require 'rails_helper'

RSpec.describe CruftTracker::RecordRenderMetadata do
  describe '#run!' do
    context 'with no metadata' do
      it 'does nothing' do
        view = CruftTracker::View.create(view: 'some/view.html.erb')
        view_render =
          CruftTracker::ViewRender.create(
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
        view_render =
          CruftTracker::ViewRender.create(
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
            metadata: {
              some: 'metadata'
            }
          )
        end.to change { CruftTracker::RenderMetadata.count }.by(1)
      end
    end

    context 'with existing metadata' do
      it 'increments the occurrences of the metadata' do
        view = CruftTracker::View.create(view: 'some/view.html.erb')
        view_render =
          CruftTracker::ViewRender.create(
            view: view,
            render_hash: '123',
            controller: 'SomeController',
            endpoint: 'some_endpoint',
            route: '/foo',
            http_method: 'PUT',
            render_stack: []
          )
        render_metadata =
          CruftTracker::RenderMetadata.create(
            view_render: view_render,
            metadata: {
              some: 'metadata'
            },
            metadata_hash: '631de6c2b97ff87eb40526dd6f11bc92',
            occurrences: 1
          )

        expect do
          CruftTracker::RecordRenderMetadata.run!(
            view_render: view_render,
            metadata: {
              some: 'metadata'
            }
          )

          render_metadata.reload
          expect(render_metadata.occurrences).to eq(2)
        end.not_to change { CruftTracker::RenderMetadata.count }
      end
    end

    it 'does not create more records than permitted by configuration' do
      view = CruftTracker::View.create(view: 'some/view.html.erb')
      view_render1 =
        CruftTracker::ViewRender.create(
          view: view,
          render_hash: '123',
          controller: 'SomeController',
          endpoint: 'some_endpoint',
          route: '/foo',
          http_method: 'DELETE',
          render_stack: []
        )
      view_render2 =
        CruftTracker::ViewRender.create(
          view: view,
          render_hash: '234',
          controller: 'OtherController',
          endpoint: 'other_endpoint',
          route: '/bar',
          http_method: 'PUT',
          render_stack: []
        )
      allow(CruftTracker::Config.instance).to receive(:max_render_metadata_variations_per_view_render).and_return(2)

      4.times do
        CruftTracker::RecordRenderMetadata.run!(
          view_render: view_render1,
          metadata: {
            uuid: SecureRandom.uuid
          }
        )
      end
      CruftTracker::RecordRenderMetadata.run!(
        view_render: view_render2,
        metadata: {
          static_value: "A horse walks into a bar..."
        }
      )

      expect(CruftTracker::RenderMetadata.where(view_render: view_render1).count).to eq(2)
      expect(CruftTracker::RenderMetadata.where(view_render: view_render2).count).to eq(1)
    end
  end
end
