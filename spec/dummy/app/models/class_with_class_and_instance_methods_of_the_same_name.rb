# frozen_string_literal: true

class ClassWithClassAndInstanceMethodsOfTheSameName
  def self.some_ambiguous_method_name
    'I am the result of a class method invocation!'
  end
  CruftTracker.is_this_method_used? self,
                                    :some_ambiguous_method_name,
                                    method_type:
                                      CruftTracker::TrackMethod::CLASS_METHOD
  def some_ambiguous_method_name
    'I am the result of an instance method invocation!'
  end
  CruftTracker.is_this_method_used? self,
                                    :some_ambiguous_method_name,
                                    method_type:
                                      CruftTracker::TrackMethod::INSTANCE_METHOD
end
