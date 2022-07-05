require 'rails_helper'

RSpec.describe CruftTracker::RecordViewRenderMetadata do
  describe '#run!' do
    context 'when the controller, endpoint, route, and render stack have not been seen together before' do
      it 'records a new metadata record' do
        view = CruftTracker::View.create(view: '/some/show.html.erb')

        expect do
        CruftTracker::RecordViewRenderMetadata.run!(
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
        end.to change { CruftTracker::RenderMetadata.count }.by(1)

        metadata = CruftTracker::RenderMetadata.first
        expect(metadata.view).to eq(view)
        expect(metadata.controller).to eq('SomeController')
        expect(metadata.endpoint).to eq('show')
        expect(metadata.route).to eq('/some:id')
        expect(metadata.render_stack).to eq(
          [
             {
               "path" => "/app/views/some/show.html.erb",
               "label" => "_app_views_some_show_html_erb__1726455257671384410_11260",
               "lineno" => 1,
               "base_label" => "_app_views_some_show_html_erb__1726455257671384410_11260"
             }
          ]
        )
        expect(metadata.occurrences).to eq(1)
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
        metadata = CruftTracker::RenderMetadata.create(
          view: view,
          render_hash: render_hash,
          controller: controller,
          endpoint: endpoint,
          route: route,
          render_stack: render_stack,
          occurrences: 123
        )

        expect do
          CruftTracker::RecordViewRenderMetadata.run!(
            view: view,
            controller: controller,
            endpoint: endpoint,
            route: route,
            render_stack: render_stack
          )
        end.to change { CruftTracker::RenderMetadata.count }.by(0)

        metadata.reload
        expect(metadata.view).to eq(view)
        expect(metadata.controller).to eq(controller)
        expect(metadata.endpoint).to eq(endpoint)
        expect(metadata.route).to eq(route)
        expect(metadata.render_stack).to eq(
          [
            {
              "path" => "/app/views/some/show.html.erb",
              "label" => "_app_views_some_show_html_erb__1726455257671384410_11260",
              "lineno" => 1,
              "base_label" => "_app_views_some_show_html_erb__1726455257671384410_11260"
            }
          ]
        )
        expect(metadata.occurrences).to eq(124)
      end
    end
  end
end
