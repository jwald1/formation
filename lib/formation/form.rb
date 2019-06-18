require 'active_model'
require 'active_model_attributes'
require 'action_controller/metal/strong_parameters'

module Formation
  class Form
    attr_reader :resource

    Error = Class.new(StandardError)
    Invalid = Class.new(Error)
    NoParamKey = Class.new(Error)

    include ActiveModel::Model
    include ActiveModelAttributes

    def self.param_key(key = nil)
      return @param_key if key.nil?

      @param_key = key
    end

    def self.auto_html5_validation(bool = true)
      @auto_html5_validation ||= bool
    end

    def initialize(*args)
      given_attributes = args.extract_options!

      if given_attributes.blank? &&
         args.last.is_a?(ActionController::Parameters)
        given_attributes = args.pop.to_unsafe_h.to_h
      end

      @resource = args.first

      given_attributes.symbolize_keys!
      given_attributes.slice!(*registered_attribute_keys)

      super(resource_attributes.merge(given_attributes))
    end

    def attributes
      @_attributes ||=
        registered_attribute_keys.map do |attribute|
          [attribute, public_send(attribute)]
        end.to_h
    end

    def save
      valid? ? persist : false
    end

    def save!
      save.tap { |saved| raise Invalid unless saved }
    end

    def persisted?
      if resource.present? && resource.respond_to?(:persisted?)
        resource.persisted?
      else
        false
      end
    end

    def to_partial_path
      nil
    end

    def to_key
      nil
    end

    def to_param
      resource.to_param if resource.present? && resource.respond_to?(:to_param)
    end

    def model_name
      @model_name ||= OpenStruct.new(model_name_attributes)
    end

    private

    def registered_attribute_keys
      self.class.attributes_registry.keys
    end

    def persist
      raise NotImplementedError, '#persist has to be implemented'
    end

    def resource_attributes
      return {} unless resource

      attributes =
        if resource.respond_to?(:attributes)
          resource.attributes.symbolize_keys
        else
          {}
        end

      attributes =
        registered_attribute_keys.map do |attribute|
          value =
            if attributes[attribute].blank?
              resource_attribute_value(attribute)
            else
              attributes[attribute]
            end

          [attribute, value]
        end.to_h

      attributes.slice(*self.class.attributes_registry.keys)
    end

    def resource_attribute_value(attribute)
      return unless resource.respond_to?(attribute)

      resource.public_send(attribute)
    end

    def model_name_attributes
      if self.class.param_key.present?
        {
          param_key: self.class.param_key,
          route_key: self.class.param_key.pluralize,
          singular_route_key: self.class.param_key
        }
      elsif resource.present? && resource.respond_to?(:model_name)
        {
          param_key: resource.model_name.param_key,
          route_key: resource.model_name.route_key,
          singular_route_key: resource.model_name.singular_route_key
        }
      else
        raise NoParamKey
      end
    end
  end
end
