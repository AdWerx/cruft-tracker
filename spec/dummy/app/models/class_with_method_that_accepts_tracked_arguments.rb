# frozen_string_literal: true

class ClassWithMethodThatAcceptsTrackedArguments
  def do_something(number, string, boolean, array, array_of_hashes, hash)
    # Pretend I do something with these args
  end

  CruftTracker.is_this_method_used? self,
                                    :do_something,
                                    track_arguments: ->(args) {
                                      args.last.keys.sort
                                    }
end
