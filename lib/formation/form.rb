require 'active_model'
require 'active_model_attributes'
require 'action_controller/metal/strong_parameters'

module Formation
  class Form
    attr_reader :model

    Error = Class.new(StandardError)
    Invalid = Class.new(Error)

    include ActiveModel::Model
    include ActiveModelAttributes

    def self.param_key(key = nil)
      return @param_key if key.nil?

      @param_key = key
    end

    def self.auto_html5_validation(bool = true)
      @auto_html5_validation ||= bool
    end

    def initialize(model: nil, params: nil)

      if params.present? && params.is_a?(ActionController::Parameters)
        params = params.to_unsafe_h.to_h
      else
        params ||= {}
      end

      @model = model

      params.symbolize_keys!
      params.slice!(*registered_attribute_keys)

      super(model_attributes.merge(params))
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
      if model.present? && model.respond_to?(:persisted?)
        model.persisted?
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
      model.to_param if model.present? && model.respond_to?(:to_param)
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

    def default_attributes
      @default_attributes ||= self.class.attributes_registry.map do |k, v|
        default_value = v.last[:default]
        default_value = default_value.respond_to?(:call) ? default_value.call(self) : default_value
        [k, default_value]
      end.to_h
    end

    def model_attributes
      return default_attributes unless model

      model_attrs =
        if model.respond_to?(:attributes)
          model.attributes.symbolize_keys
        else
          {}
        end

      registered_attribute_keys.map do |attribute|
        value = model_attrs[attribute] || model_attribute_value(attribute) || default_attributes[attribute]

        [attribute, value]
      end.to_h
    end

    def model_attribute_value(attribute)
      return unless model.respond_to?(attribute)

      model.public_send(attribute)
    end

    def model_name_attributes
      if self.class.param_key.present?
        {
          param_key: self.class.param_key,
          route_key: self.class.param_key.pluralize,
          singular_route_key: self.class.param_key
        }
      else
        class_name = self.class.name.sub('Form', '').underscore
        {
          param_key: class_name,
          route_key: class_name.pluralize,
          singular_route_key: class_name
        }
      end
    end
  end
end
