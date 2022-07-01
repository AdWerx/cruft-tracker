
CruftTracker.init do
  # TODO: add config options here such as:
  # - max num of backtraces / arguments
  # - max backtrace stack
  # - filters for backtraces

  are_any_of_these_methods_being_used? ClassThatIsTrackingAllMethods

  # TODO: I'm not sure if this should raise or log...
  # is_this_method_used? ClassTrackingMethodThatDoesNotExist, :some_missing_method_name

  is_this_method_used? ClassWithClassAndInstanceMethodsOfTheSameName,
                       :some_ambiguous_method_name,
                       method_type: CruftTracker::Method::CLASS_METHOD

  is_this_method_used? ClassWithClassAndInstanceMethodsOfTheSameName,
                       :some_ambiguous_method_name,
                       method_type: CruftTracker::Method::INSTANCE_METHOD

  # TODO: I'm not sure if this should raise or log...
  # is_this_method_used? ClassWithClassAndInstanceMethodsOfTheSameNameThatAreNotDisambiguated,
  #                      :some_ambiguous_method_name

  is_this_method_used? ClassWithHashComment,
                       :some_method,
                       comment: {
                         foo: true,
                         bar: [1, 'two']
                       }

  is_this_method_used? ClassWithMethodThatAcceptsTrackedArguments,
                       :do_something,
                       track_arguments: ->(args) {
                         args.last.keys.sort
                       }

  is_this_method_used? ClassWithMethodThatAcceptsUntrackedArguments, :describe_thing

  is_this_method_used? ClassWithMultipleBacktracesToTheSameTrackedMethod, :tracked_method

  is_this_method_used? ClassWithPrivateClassMethod, :be_sneaky

  is_this_method_used? ClassWithPrivateEigenclassMethod, :super_private_class_method

  is_this_method_used? ClassWithPrivateInstanceMethod, :some_private_method

  is_this_method_used? ClassWithProtectedInstanceMethod, :some_protected_method

  is_this_method_used? ClassWithTaggedClassMethod, :some_class_method

  is_this_method_used? ClassWithTaggedInstanceMethod, :some_instance_method

  is_this_method_used? ClassWithTextualComment,
                       :some_method,
                       comment: 'Tracking is fun!'

  is_this_method_used? ClassWithTaggedInstanceMethod, :some_instance_method

  are_any_of_these_methods_being_used? ModuleThatIsTrackingAllMethods

  is_this_method_used? ModuleWithTaggedMethod, :some_module_method

  is_this_method_used? SubclassWithTrackedMethod, :hello

  is_this_view_used? 'app/views/main/show.html.erb', comment: "Look at that view!"
  is_this_view_used? 'app/views/shared/_whatever.html.erb'
  is_this_view_used? 'app/views/numbers/show.html.erb'

  # this do block could run code afterwards to clean up any tracking we're no longer doing.
  # maybe the argument is cruft_tracker_config?
  # maybe I look into some the dsl stuff and see if I can't define something like:
  #
  #    is_this_method_used? ClassWithTextualComment,
  #                         :some_method,
  #                         comment: 'Tracking is fun!'
  #
  # such that is_this_method_used? is resolved magically somehow?
end