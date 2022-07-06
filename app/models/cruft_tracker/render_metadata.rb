# frozen_string_literal: true

module CruftTracker
  class RenderMetadata < ActiveRecord::Base
    belongs_to :view_render, class_name: 'CruftTracker::ViewRender'
  end
end
