# frozen_string_literal: true

class ClassWithProtectedInstanceMethod
  def do_something
    some_protected_method
  end

  protected

  def some_protected_method
    'I am safely protected'
  end
end
