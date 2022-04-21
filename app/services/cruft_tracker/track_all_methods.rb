# frozen_string_literal: true

module CruftTracker
  class TrackAllMethods < CruftTracker::ApplicationService
    object :owner, class: Object
    object :comment, class: Object, default: nil

    private

    def execute
      method_records = []
      method_records +=
        own_instance_methods.map do |instance_method|
          CruftTracker::TrackMethod.run!(
            owner: owner,
            name: instance_method,
            method_type: CruftTracker::Method::INSTANCE_METHOD,
            comment: comment
          )
        end
      method_records +=
        own_class_methods.map do |class_method|
          CruftTracker::TrackMethod.run!(
            owner: owner,
            name: class_method,
            method_type: CruftTracker::Method::CLASS_METHOD,
            comment: comment
          )
        end

      method_records.flatten
    end

    def own_instance_methods
      owner.instance_methods(false) + owner.private_instance_methods(false)
    end

    def own_class_methods
      owner.methods(false) +
        owner
          .private_methods(false)
          .select do |method|
            owner.method(method).owner.inspect === owner.singleton_class.inspect
          end
    end
  end
end
