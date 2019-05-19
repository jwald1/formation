require 'active_model'
require 'active_model_attributes'
require "action_controller/metal/strong_parameters"

module Formation
  class Form
    attr_reader :resource

    Error = Class.new(StandardError)
    Invalid = Class.new(Error)
    NoParamKey = Class.new(Error)

    include ActiveModel::Model
    include ActiveModelAttributes

    def self.param_key(key = nil)
      if key.nil?
        @param_key
      else
        @param_key = key
      end
    end

    def initialize(*args)
      attributes = args.extract_options!

      if attributes.blank? && args.last.is_a?(ActionController::Parameters)
        attributes = args.pop.to_unsafe_h
      end

      @resource = args.first

      registered_attribute_keys = self.class.attributes_registry.keys.map(&:to_sym)
      attributes.to_h.symbolize_keys!
      attributes.slice!(*registered_attribute_keys)

      super(resource_attributes.merge(attributes))
    end

    def attributes
      @_attributes ||= self.class.attributes_registry.keys.map do |attribute|
        [attribute, public_send(attribute)]
      end.to_h
    end

    def save
      valid? ? persist : false
    end

    def save!
      save.tap do |saved|
        raise Invalid unless saved
      end
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
      if resource.present? && resource.respond_to?(:to_param)
        resource.to_param
      else
        nil
      end
    end

    def model_name
      @model_name ||= OpenStruct.new(model_name_attributes)
    end

    private

    def persist
      raise NotImplementedError, "#persist has to be implemented"
    end

    def resource_attributes
      return {} unless resource
      attributes = resource.attributes.symbolize_keys
      attributes.slice(*self.class.attributes_registry.keys)
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