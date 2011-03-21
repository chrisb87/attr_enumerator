require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern

  DEFAULT_OPTIONS = {
    :generate_constant => true,
    :generate_methods => true,
    :generate_scopes => true,
    :message => :invalid,
    :prefix => true,
    :suffix => ''
  }

  module ClassMethods
    def attr_enumerator(field, enumerators, opts={})
      options = opts.reverse_merge(DEFAULT_OPTIONS)

      generate_constant = options.delete(:generate_constant)
      generate_methods = options.delete(:generate_methods)
      generate_scopes = options.delete(:generate_scopes)

      prefix = options.delete(:prefix)
      prefix = { true => field.to_s + '_', false => '' }[prefix] || prefix.to_s
      suffix = options.delete(:suffix).to_s

      if generate_constant
        const_name = generate_constant == true ? field.to_s.pluralize.upcase : generate_constant.to_s
        const_set(const_name, enumerators).freeze
      end

      enumerators.each do |enumerator|
        formatted_enumerator = prefix + enumerator.to_s.underscore.parameterize('_') + suffix

        if generate_methods
          define_method(formatted_enumerator + '?'){ self.send(field) == enumerator }
        end

        if generate_scopes && self.respond_to?(:scope)
          scope formatted_enumerator, where(field => enumerator)
        end
      end

      validates_inclusion_of field, options.merge(:in => enumerators)
    end
  end
end

ActiveRecord::Base.class_eval { include AttrEnumerator } if defined? ActiveRecord
