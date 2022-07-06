# frozen_string_literal: true

module CruftTracker
  class RecordViewRender < CruftTracker::ApplicationService
    record :view, class: CruftTracker::View
    string :controller
    string :endpoint
    string :route
    string :http_method
    array :render_stack do
      hash do
        string :path
        string :label
        string :base_label
        integer :lineno
      end
    end
    interface :metadata, methods: %i[to_json], default: nil

    private

    def execute
      CruftTracker::LogSuppressor.suppress_logging do
        view.with_lock do
          view.reload
          view.update(renders: view.renders + 1)
        end

        view_render_record.with_lock do
          view_render_record.reload
          view_render_record.update(
            occurrences: view_render_record.occurrences + 1
          )

          record_render_metadata(view_render_record)

          view_render_record
        end
      end
    end

    def record_render_metadata(view_render_record)
      compose(
        CruftTracker::RecordRenderMetadata,
        view_render: view_render_record,
        metadata: metadata
      )
    end

    def view_render_record
      @view_render_record ||=
        begin
          CruftTracker::ViewRender.create(
            view: view,
            render_hash: render_hash,
            controller: controller,
            endpoint: endpoint,
            route: route,
            http_method: http_method,
            render_stack: render_stack
          )
        rescue ActiveRecord::RecordNotUnique
          CruftTracker::ViewRender.find_by(render_hash: render_hash)
        end
    end

    def render_hash
      Digest::MD5.hexdigest(
        {
          controller: controller,
          endpoint: endpoint,
          route: route,
          http_method: http_method,
          render_stack: render_stack.to_json
        }.to_json
      )
    end
  end
end
