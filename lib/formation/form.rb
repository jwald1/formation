require 'active_model'
require 'action_controller/metal/strong_parameters'

module Formation
  class Form
    attr_reader :model

    Error = Class.new(StandardError)
    Invalid = Class.new(Error)

    include ActiveModel::Model
    include ActiveModel::Attributes

    def self.param_key(key = nil)
      return @param_key if key.nil?

      @param_key = key
    end

    def self.auto_html5_validation(bool = true)
      @auto_html5_validation ||= bool
    end

    def initialize(model: nil, params: {})
      if params.present? && params.is_a?(ActionController::Parameters)
        params = params.to_unsafe_h.to_h
      else
        params ||= {}
      end

      @model = model

      
      params.symbolize_keys!
      params.slice!(*registered_attribute_keys.map(&:to_sym))
      filter_params = params.select { |_, value| value.present? }

      super(**filter_params)
      # does attributes that doesn't have a value and there key is not present in params
      attributes.select do |key, value|
        next if value.present? || params.key?(key.to_s) || params.key?(key.to_sym)

        value = model.respond_to?(:attributes) ? model.attributes[key.to_s] || model.attributes[key.to_sym] : model.try(key)
        self.send("#{key}=", value)
      end
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
      @keys ||= self.class._default_attributes.to_h.keys
    end

    def persist
      raise NotImplementedError, '#persist has to be implemented'
    end

    # def default_attributes
    #   binding.pry
    #   @default_attributes ||= self.class._default_attributes.each_value.to_a.map do |attribute|
    #     default_value = v.last[:default]
    #     default_value = default_value.respond_to?(:call) ? default_value.call(self) : default_value
    #     [k, default_value]
    #   end.to_h
    # end

    # def model_attributes
    #   return default_attributes unless model

    #   model_attrs =
    #     if model.respond_to?(:attributes)
    #       model.attributes.symbolize_keys
    #     else
    #       {}
    #     end

    #   registered_attribute_keys.map do |attribute|
    #     value = if model_attrs[attribute].present?
    #       model_attrs[attribute]
    #     elsif model_attribute_value(attribute).present?
    #       model_attribute_value(attribute)
    #     else
    #       default_attributes[attribute]
    #     end

    #     [attribute, value]
    #   end.to_h
    # end

    # def model_attribute_value(attribute)
    #   return unless model.respond_to?(attribute)

    #   model.public_send(attribute)
    # end

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
