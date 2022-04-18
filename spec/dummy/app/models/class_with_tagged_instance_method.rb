# frozen_string_literal: true
class ClassWithTaggedInstanceMethod
  def initialize
    @counter = 0
  end

  def some_instance_method
    @counter += 1

    "Foobar #{@counter}"
  end

  CruftTracker.is_this_method_used? self, :some_instance_method
end
