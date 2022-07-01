# frozen_string_literal: true

class ClassWithMethodThatAcceptsUntrackedArguments
  def describe_thing(color, weight)
    "The thing is #{color} and weighs #{weight} firkins."
  end
end
