# frozen_string_literal: true

class ClassWithPrivateInstanceMethod
  def do_something
    some_private_method
  end

  private

  def some_private_method
    "Shhh! nobody knows I'm here!"
  end

  CruftTracker.is_this_method_used? self, :some_private_method
end
