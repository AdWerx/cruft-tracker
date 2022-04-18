# frozen_string_literal: true

module CruftTracker
  # TODO: test me?
  class RecordBacktrace < ApplicationService
    record :method, class: CruftTracker::Method

    private

    def execute
      binding.pry
    end
  end
end
