# frozen_string_literal: true

module CruftTracker
  # Records provided metadata associated with a given render
  class RecordRenderMetadata < CruftTracker::ApplicationService
    record :view_render, class: CruftTracker::ViewRender
    interface :metadata, methods: %i[to_json], default: nil

    private

    def execute
      return unless metadata.present?

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
            view_render: view_render,
            metadata_hash: metadata_hash,
            metadata: metadata
          )
        rescue ActiveRecord::RecordNotUnique
          CruftTracker::RenderMetadata.find_by(metadata_hash: metadata_hash)
        end
    end

    def metadata_hash
      Digest::MD5.hexdigest([view_render.id, metadata].to_json)
    end
  end
end
