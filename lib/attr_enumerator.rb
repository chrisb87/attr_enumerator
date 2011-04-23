require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern
  
  module ClassMethods
    def attr_enumerator(field, options = {})
      choices = options[:in]
      constant = options.delete(:constant) || field.to_s.pluralize.upcase
      options[:message] ||= :invalid
      
      const_set(constant, choices).freeze
      validates field, :inclusion => options
      
      choice_prefix = options.has_key?(:prefix) ? (options[:prefix] ? options[:prefix].to_s + '_' : '') : field.to_s + '_'

      choices.each do |choice|
        field_choice = choice_prefix + choice.to_s.underscore.parameterize('_')
        define_method("#{field_choice}?") do
          self.send(field) == choice
        end
        scope field_choice, where(field => choice) if self.respond_to? :scope
      end
    end
  end
end

ActiveRecord::Base.send :include, AttrEnumerator if defined? ActiveRecord
