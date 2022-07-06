# frozen_string_literal: true

class ClassWithMultipleBacktracesToTheSameTrackedMethod
  def kick_off_the_thing_to_do_twice
    2.times { kick_off_the_thing_to_do }
  end

  def kick_off_the_thing_to_do
    do_the_thing
  end

  private

  def do_the_thing
    tracked_method
  end

  def tracked_method
    'I am tracked'
  end
end
