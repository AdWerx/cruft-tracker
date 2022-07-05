# frozen_string_literal: true

module CruftTracker
  class ViewRender < ActiveRecord::Base
    belongs_to :view, class_name: 'CruftTracker::View'
    has_many :render_metadata, class_name: 'CruftTracker::RenderMetadata'
  end
end
