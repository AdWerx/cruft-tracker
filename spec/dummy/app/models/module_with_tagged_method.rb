# frozen_string_literal: true

module ModuleWithTaggedMethod
  def self.some_module_method
    'Widdershins'
  end
  CruftTracker.is_this_method_used? self, :some_module_method
end
