CruftTracker.init do
  config.max_argument_variations_per_tracked_method = 5
  config.max_backtrace_variations_per_tracked_method = 5
  config.max_metadata_variations_per_view_render = 5
  config.max_view_renders_per_view = 5

  # TODO: add config options here such as:
  # - max num of backtraces / arguments
  # - max backtrace stack
  # - filters for backtraces

  is_this_method_used?(
    ClassWithClassAndInstanceMethodsOfTheSameName,
    :some_ambiguous_method_name,
    method_type: CruftTracker::Method::CLASS_METHOD
  )
  is_this_method_used?(
    ClassWithClassAndInstanceMethodsOfTheSameName,
    :some_ambiguous_method_name,
    method_type: CruftTracker::Method::INSTANCE_METHOD
  )

  is_this_method_used?(
    ClassWithHashComment,
    :some_method,
    comment: {
      foo: true,
      bar: [1, 'two']
    }
  )

  is_this_method_used?(
    ClassWithMethodThatAcceptsTrackedArguments,
    :do_something,
    track_arguments: ->(args) { args.last.keys.sort }
  )

  is_this_method_used?(
    ClassWithMethodThatAcceptsUntrackedArguments,
    :describe_thing
  )
  is_this_method_used?(
    ClassWithMultipleBacktracesToTheSameTrackedMethod,
    :tracked_method
  )
  is_this_method_used?(ClassWithPrivateClassMethod, :be_sneaky)
  is_this_method_used?(
    ClassWithPrivateEigenclassMethod,
    :super_private_class_method
  )
  is_this_method_used?(ClassWithPrivateInstanceMethod, :some_private_method)
  is_this_method_used?(ClassWithProtectedInstanceMethod, :some_protected_method)
  is_this_method_used?(ClassWithTaggedClassMethod, :some_class_method)
  is_this_method_used?(ClassWithTaggedInstanceMethod, :some_instance_method)
  is_this_method_used?(
    ClassWithTextualComment,
    :some_method,
    comment: 'Tracking is fun!'
  )
  is_this_method_used?(ModuleWithTaggedMethod, :some_module_method)
  is_this_method_used?(SubclassWithTrackedMethod, :hello)

  are_any_of_these_methods_being_used?(ClassThatIsTrackingAllMethods)
  are_any_of_these_methods_being_used?(ModuleThatIsTrackingAllMethods)

  is_this_view_used?(
    'app/views/main/show.html.erb',
    comment: 'Look at that view!'
  )
  is_this_view_used?('app/views/shared/_whatever.html.erb')
  is_this_view_used?('app/views/numbers/show.html.erb')
end
