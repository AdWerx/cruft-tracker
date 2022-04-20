# frozen_string_literal: true

class ClassWithUntrackedMethod
  def hello
    'hi'
  end

  def another_untracked_method
    'I just quietly do my job.'
  end
end
