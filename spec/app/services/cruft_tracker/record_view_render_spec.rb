require 'rails_helper'

RSpec.describe CruftTracker::RecordViewRender do
  describe '#run!' do
    context 'when the controller, endpoint, route, and render stack have not been seen together before' do
      it 'records a new render record' do
        view = CruftTracker::View.create(view: '/some/show.html.erb')

        expect do
          CruftTracker::RecordViewRender.run!(
            view: view,
            controller: 'SomeController',
            endpoint: 'show',
            route: '/some:id',
            render_stack:[
              {
                path: "/app/views/some/show.html.erb",
                label: "_app_views_some_show_html_erb__1726455257671384410_11260",
                lineno: 1,
                base_label: "_app_views_some_show_html_erb__1726455257671384410_11260"
              }]
          )
        end.to change { CruftTracker::ViewRender.count }.by(1)

        view_render = CruftTracker::ViewRender.first
        expect(view_render.view).to eq(view)
        expect(view_render.controller).to eq('SomeController')
        expect(view_render.endpoint).to eq('show')
        expect(view_render.route).to eq('/some:id')
        expect(view_render.render_stack).to eq(
          [
             {
               "path" => "/app/views/some/show.html.erb",
               "label" => "_app_views_some_show_html_erb__1726455257671384410_11260",
               "lineno" => 1,
               "base_label" => "_app_views_some_show_html_erb__1726455257671384410_11260"
             }
          ]
        )
        expect(view_render.occurrences).to eq(1)
      end

      context 'with metadata provided' do
        it 'records the metadata' do
          view = CruftTracker::View.create(view: '/some/show.html.erb')
          metadata = { some_data: [1, true, { a: 'b' }], something_else: nil }

          expect do
            view_render = CruftTracker::RecordViewRender.run!(
              view: view,
              controller: 'SomeController',
              endpoint: 'show',
              route: '/some:id',
              render_stack:[
                {
                  path: "/app/views/some/show.html.erb",
                  label: "_app_views_some_show_html_erb__1726455257671384410_11260",
                  lineno: 1,
                  base_label: "_app_views_some_show_html_erb__1726455257671384410_11260"
                }],
              metadata: metadata
            )

            render_metadata = view_render.render_metadata.first
            expect(render_metadata.metadata_hash).not_to be_nil
            expect(render_metadata.occurrences).to eq(1)

          end.to change { CruftTracker::RenderMetadata.count }.by(1)
        end
      end
    end

    context 'when the controller, endpoint, route, and render stack have been seen together before' do
      it 'increments the number of occurrences' do
        view = CruftTracker::View.create(view: '/some/show.html.erb')
        controller = 'SomeController'
        endpoint = 'show'
        route = '/some/:id'
        render_stack = [
          {
            path: "/app/views/some/show.html.erb",
            label: "_app_views_some_show_html_erb__1726455257671384410_11260",
            base_label: "_app_views_some_show_html_erb__1726455257671384410_11260",
            lineno: 1
          }
        ]
        render_hash = Digest::MD5.hexdigest(
          {
            controller: controller,
            endpoint: endpoint,
            route: route,
            render_stack: render_stack.to_json
          }.to_json
        )
        view_render = CruftTracker::ViewRender.create(
          view: view,
          render_hash: render_hash,
          controller: controller,
          endpoint: endpoint,
          route: route,
          render_stack: render_stack,
          occurrences: 123
        )

        expect do
          CruftTracker::RecordViewRender.run!(
            view: view,
            controller: controller,
            endpoint: endpoint,
            route: route,
            render_stack: render_stack
          )
        end.to change { CruftTracker::ViewRender.count }.by(0)

        view_render.reload
        expect(view_render.view).to eq(view)
        expect(view_render.controller).to eq(controller)
        expect(view_render.endpoint).to eq(endpoint)
        expect(view_render.route).to eq(route)
        expect(view_render.render_stack).to eq(
          [
            {
              "path" => "/app/views/some/show.html.erb",
              "label" => "_app_views_some_show_html_erb__1726455257671384410_11260",
              "lineno" => 1,
              "base_label" => "_app_views_some_show_html_erb__1726455257671384410_11260"
            }
          ]
        )
        expect(view_render.occurrences).to eq(124)
      end

      context 'with metadata provided' do
        it 'increments the metadata occurrences' do
          metadata = { some_data: [1, true, { a: 'b' }], something_else: nil }
          view = CruftTracker::View.create(view: '/some/show.html.erb')
          controller = 'SomeController'
          endpoint = 'show'
          route = '/some/:id'
          render_stack = [
            {
              path: "/app/views/some/show.html.erb",
              label: "_app_views_some_show_html_erb__1726455257671384410_11260",
              base_label: "_app_views_some_show_html_erb__1726455257671384410_11260",
              lineno: 1
            }
          ]
          render_hash = Digest::MD5.hexdigest(
            {
              controller: controller,
              endpoint: endpoint,
              route: route,
              render_stack: render_stack.to_json
            }.to_json
          )
          view_render = CruftTracker::ViewRender.create(
            view: view,
            render_hash: render_hash,
            controller: controller,
            endpoint: endpoint,
            route: route,
            render_stack: render_stack,
            occurrences: 123
          )
          metadata_hash = Digest::MD5.hexdigest([view_render.render_hash, metadata].to_json)
          render_metadata = CruftTracker::RenderMetadata.create(
            view_render: view_render,
            metadata_hash: metadata_hash,
            metadata: metadata,
            occurrences: 234
          )

          expect do
            CruftTracker::RecordViewRender.run!(
              view: view,
              controller: controller,
              endpoint: endpoint,
              route: route,
              render_stack: render_stack,
              metadata: metadata
            )

            render_metadata.reload
            expect(render_metadata.occurrences).to eq(235)
          end.to change { CruftTracker::RenderMetadata.count }.by(0)
        end
      end
    end
  end
end
