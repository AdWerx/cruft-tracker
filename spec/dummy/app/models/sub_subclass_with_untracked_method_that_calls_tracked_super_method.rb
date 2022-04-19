# frozen_string_literal: true

class SubSubclassWithUntrackedMethodThatCallsTrackedSuperMethod < SubclassWithTrackedMethod
  def hello
    "#{super}!!!!!!!!!!"
  end
end
