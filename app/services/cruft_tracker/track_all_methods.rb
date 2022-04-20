# frozen_string_literal: true

module CruftTracker
  # TODO: test me
  class TrackAllMethods < CruftTracker::ApplicationService
    object :owner, class: Module
    object :comment, class: Object, default: nil

    private

    def execute
      own_instance_methods.each do |instance_method|
        CruftTracker::TrackMethod.run!(
          owner: owner,
          name: instance_method,
          method_type: CruftTracker::TrackMethod::INSTANCE_METHOD,
          comment: comment
        )
      end
      own_class_methods.each do |class_method|
        CruftTracker::TrackMethod.run!(
          owner: owner,
          name: class_method,
          method_type: CruftTracker::TrackMethod::CLASS_METHOD,
          comment: comment
        )
      end
    end

    def own_instance_methods
      owner.instance_methods(false) + owner.private_instance_methods(false)
    end

    def own_class_methods
      owner.methods(false) + owner.private_methods(false) -
        %i[initialize inherited]
    end
  end
end
