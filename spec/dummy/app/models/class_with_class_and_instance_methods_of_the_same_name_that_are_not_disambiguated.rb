# frozen_string_literal: true

class ClassWithClassAndInstanceMethodsOfTheSameNameThatAreNotDisambiguated
  def self.some_ambiguous_method_name
    'I am the result of a class method invocation!'
  end

  def some_ambiguous_method_name
    'I am the result of an instance method invocation!'
  end
end
