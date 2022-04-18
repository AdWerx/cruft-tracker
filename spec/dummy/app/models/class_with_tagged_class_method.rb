# frozen_string_literal: true

class ClassWithTaggedClassMethod
  def self.some_class_method
    'Look mom! No hands!'
  end

  CruftTracker.is_this_method_used? self, :some_class_method
end
