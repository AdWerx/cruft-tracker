# frozen_string_literal: true

class ClassWithPrivateInstanceMethod
  def do_something
    some_private_method
  end

  private

  def some_private_method
    "Shhh! nobody knows I'm here!"
  end
end
