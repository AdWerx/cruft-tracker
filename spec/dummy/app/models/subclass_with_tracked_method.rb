# frozen_string_literal: true

class SubclassWithTrackedMethod < ClassWithUntrackedMethod
  attr_accessor :name

  def initialize(name)
    super()
    @name = name
  end

  def hello
    "Hi, #{name}"
  end

  def i_am_not_to_be_overridden
    'RAR! Fear me!'
  end
end
