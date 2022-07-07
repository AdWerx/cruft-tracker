# frozen_string_literal: true

module CruftTracker
  # Records provided metadata associated with a given render
  class RecordRenderMetadata < CruftTracker::ApplicationService
    record :view_render, class: CruftTracker::ViewRender
    interface :metadata, methods: %i[to_json], default: nil

    private

    def execute
      return unless metadata.present?
      return unless render_metadata_record.present?

      CruftTracker::LogSuppressor.suppress_logging do
        render_metadata_record.with_lock do
          render_metadata_record.reload
          render_metadata_record.update(
            occurrences: render_metadata_record.occurrences + 1
          )
        end
      end
    end

    def render_metadata_record
      @render_metadata_record ||=
        begin
          return find_existing_render_metadata_record if max_records_reached?

          CruftTracker::RenderMetadata.create(
            view_render: view_render,
            metadata_hash: metadata_hash,
            metadata: metadata
          )
        rescue ActiveRecord::RecordNotUnique
          find_existing_render_metadata_record
        end
    end

    def find_existing_render_metadata_record
      CruftTracker::RenderMetadata.find_by(metadata_hash: metadata_hash)
    end

    def metadata_hash
      Digest::MD5.hexdigest([view_render.render_hash, metadata].to_json)
    end

    def max_records_reached?
      CruftTracker::RenderMetadata.where(view_render: view_render).count >= CruftTracker.config.max_render_metadata_variations_per_view_render
    end
  end
end
