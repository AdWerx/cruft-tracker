# frozen_string_literal: true

module CruftTracker
  class RecordViewRenderMetadata < CruftTracker::ApplicationService
    record :view, class: CruftTracker::View
    string :controller
    string :endpoint
    string :route
    array :render_stack do
      hash do
        string :path
        string :label
        string :base_label
        integer :lineno
      end
    end

    private

    def execute
      CruftTracker::LogSuppressor.suppress_logging do
        render_metadata_record.with_lock do
          render_metadata_record.reload
          render_metadata_record.update(occurrences: render_metadata_record.occurrences + 1)
        end
      end
    end

    def render_metadata_record
      @render_metadata_record ||=
        begin
          CruftTracker::RenderMetadata.create(
            view: view,
            render_hash: render_hash,
            controller: controller,
            endpoint: endpoint,
            route: route,
            render_stack: render_stack
          )
        rescue ActiveRecord::RecordNotUnique
          CruftTracker::RenderMetadata.find_by(render_hash: render_hash)
        end
    end

    def render_hash
      Digest::MD5.hexdigest(
        {
          controller: controller,
          endpoint: endpoint,
          route: route,
          render_stack: render_stack.to_json
        }.to_json
      )
    end

  end
end
