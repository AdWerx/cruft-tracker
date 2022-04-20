# frozen_string_literal: true

class ClassTrackingMethodThatDoesNotExist
  if Rails.env.test?
    CruftTracker.is_this_method_used? self, :some_missing_method_name
  end
end
