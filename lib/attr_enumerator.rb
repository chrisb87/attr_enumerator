require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_enumerator(attribute, choices, options = {})
      constant = options.delete(:constant) || attribute.to_s.pluralize.upcase
      prefix = options[:prefix] ? options.delete(:prefix).to_s + '_' : ''
      options[:message] ||= :invalid

      const_set(constant, choices).freeze
      validates_inclusion_of attribute, options.merge(:in => choices)

      choices.each do |choice|
        choice_string = prefix + choice.to_s.underscore.parameterize('_')
        define_method(choice_string + '?') { send(attribute) == choice }
        scope choice_string, lambda { where(attribute => choice) } if respond_to? :scope
      end
    end
  end
end

ActiveSupport.on_load(:active_record) { include AttrEnumerator }
