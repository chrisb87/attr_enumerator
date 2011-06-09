require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_enumerator(field, choices, options = {})
      constant = options.delete(:constant) || field.to_s.pluralize.upcase
      const_set(constant, choices).freeze

      raw_prefix = options.delete(:prefix)

      prefix = case raw_prefix
      when false, '' then ''
      when nil then field.to_s + '_'
      else raw_prefix.to_s + '_'
      end

      choices.each do |choice|
        formatted_choice = prefix + choice.to_s.underscore.parameterize('_')

        define_method(formatted_choice + '?') { send(field) == choice }
        
        if self.respond_to? :scope        
          scope formatted_choice, where(field => choice) if respond_to? :scope
        elsif self.respond_to? :named_scope
          named_scope formatted_choice, :conditions => {field => choice}
        end
      end

      options[:message] ||= :invalid
      
      validates_inclusion_of field, options.merge(:in => choices)
    end
  end
end

ActiveSupport.on_load(:active_record) { include AttrEnumerator }
