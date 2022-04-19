# frozen_string_literal: true

class ClassWithPrivateEigenclassMethod
  class << self
    private

    def super_private_class_method
      'kapow'
    end
  end
  CruftTracker.is_this_method_used? self, :super_private_class_method

  def self.do_it
    self.super_private_class_method
  end
end
