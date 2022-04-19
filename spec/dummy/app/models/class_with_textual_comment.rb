# frozen_string_literal: true

class ClassWithTextualComment
  def some_method
    'Woot'
  end

  CruftTracker.is_this_method_used? self,
                                    :some_method,
                                    comment: 'Tracking is fun!'
end
