# frozen_string_literal: true

class ClassWithHashComment
  def some_method
    'Woot'
  end

  CruftTracker.is_this_method_used? self,
                                    :some_method,
                                    comment: {
                                      foo: true,
                                      bar: [1, 'two']
                                    }
end
