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
        const_name = constant == true ? field.to_s.pluralize.upcase : constant.to_s
        const_set(const_name, enumerators).freeze unless const_defined?(const_name)
      end

      method_prefix = options.delete(:prefix)
      enumerators.each do |enumerator|
        method_name = method_prefix + enumerator.to_s.underscore.parameterize('_') + '?'
        define_method(method_name) do
          self.send(field) == enumerator
        end
      end

      validates_inclusion_of field, options.merge({ :in => enumerators })
    end
  end
end

ActiveRecord::Base.class_eval { include AttrEnumerator } if defined? ActiveRecord
