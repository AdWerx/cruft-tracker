# frozen_string_literal: true
class ClassWithTaggedInstanceMethod
  def some_instance_method
    puts '>>>> got here'
  end

  CruftTracker.is_this_method_used? self, :some_instance_method
end
