require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern

  DEFAULT_OPTIONS = {
    :constant => true, 
    :prefix => '', 
    :message => :invalid
  }

  module ClassMethods
    def attr_enumerator(field, enumerators, opts={})
      options = opts.reverse_merge(DEFAULT_OPTIONS)

      unless !(constant = options.delete(:constant))
        constant = field.to_s.pluralize.upcase if constant == true
        const_set(constant.to_s, enumerators).freeze unless const_defined?(constant)
      end

      prefix = options.delete(:prefix)
      enumerators.each do |enumerator|
        define_method(prefix + enumerator.to_s.underscore.parameterize('_') + '?') do
          self.send(field) == enumerator
        end
      end

      validates_inclusion_of field, options.merge({ :in => enumerators })
    end
  end
end

ActiveRecord::Base.class_eval { include AttrEnumerator } if defined? ActiveRecord
