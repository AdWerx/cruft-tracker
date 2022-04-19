# frozen_string_literal: true

class SubSubclassWithUntrackedMethod < SubclassWithTrackedMethod
  def hello
    "Greetings to you, #{name}! Cromulent day, is it not?"
  end
end
