require 'active_model'
require 'active_support'

module AttrEnumerator
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_enumerator(field, choices, opts={})
      options = Options.parse(field, choices, opts, self)

      validates field, :inclusion => options[:validation_options]

      if options[:create_constant]
        const_set(options[:constant], choices).freeze
      end

      options[:formatted_choices].each do |formatted_choice, choice|
        if options[:create_methods]
          define_method(formatted_choice + '?'){ self.send(field) == choice }
        end

        if options[:create_scopes]
          scope formatted_choice, where(field => choice)
        end
      end
    end
  end

  class Options
    include ActiveSupport::Configurable

    config.create_constant  = true
    config.create_methods   = true
    config.create_scopes    = true
    config.prefix           = true
    config.suffix           = false
    config.message          = :invalid

    VALIDATION_OPTIONS = [:in, :message, :allow_nil, :allow_blank, :if, :unless].freeze

    def self.parse(field, choices, opts, klass)
      {}.merge!(config).merge!(opts).merge!(:in => choices).tap do |options|
        options[:validation_options] = options.slice(*VALIDATION_OPTIONS)
        options.reject!{|k,v| VALIDATION_OPTIONS.include?(k)}

        options[:create_scopes] &= klass.respond_to?(:scope)

        [:prefix, :suffix].each do |affix|
          options[affix] = case options[affix]
          when true then field.to_s
          when false then nil
          else options[affix].to_s
          end
        end

        options[:constant] = case options[:create_constant]
        when true then field.to_s.pluralize.upcase
        when false then nil
        else options[:create_constant].to_s
        end

        options[:formatted_choices] = choices.map do |choice|
          formatted_choice = choice.to_s.underscore.parameterize('_')
          formatted_choice.insert(0, options[:prefix] + '_') unless options[:prefix].blank?
          formatted_choice << '_' + options[:suffix] unless options[:suffix].blank?
          [formatted_choice, choice]
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval { include AttrEnumerator } if defined? ActiveRecord
