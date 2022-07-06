# frozen_string_literal: true

module CruftTracker
  # creates or updates a CruftTracker:View record and configures subscriptions for render events
  class TrackView < CruftTracker::ApplicationService
    private

    string :view
    interface :comment, methods: %i[to_json], default: nil

    def execute
      view_record =
        CruftTracker::LogSuppressor.suppress_logging do
          view_record = create_or_find_view_record
          view_record.deleted_at = nil
          view_record.comment = comment if comment != view_record.comment
          view_record.save
          view_record
        end

      listen_for_render(view_record)

      CruftTracker::Registry << view_record

      view_record
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.cause.present? && e.cause.instance_of?(Mysql2::Error)

      Rails.logger.warn(
        'CruftTracker was unable to record a view. Does the cruft_tracker_views table exist? Have migrations been run?'
      )
    rescue NoMethodError
      Rails.logger.warn(
        'CruftTracker was unable to record a view. Have migrations been run?'
      )
    rescue Mysql2::Error::ConnectionError,
           ActiveRecord::ConnectionNotEstablished
      Rails.logger.warn(
        'CruftTracker was unable to record a view due to being unable to connect to the database. This may be a non-issue in cases where the database is intentionally not available.'
      )
    end

    def listen_for_render(view_record)
      ActiveSupport::Notifications.subscribe /!render_.*\.action_view/ do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        if event.payload[:identifier] == "#{Rails.root}/#{view}"
          CruftTracker::IncrementViewRenders.run!(view: view_record.id)
        end
      rescue StandardError
        # suppress errors
      end
    end

    def create_or_find_view_record
      CruftTracker::View.create(view: view, comment: comment)
    rescue ActiveRecord::RecordNotUnique
      CruftTracker::View.find_by(view: view)
    end
  end
end
