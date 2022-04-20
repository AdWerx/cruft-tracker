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

  CruftTracker.is_this_method_used? self, :hello

  def i_am_not_to_be_overridden
    'RAR! Fear me!'
  end
end
