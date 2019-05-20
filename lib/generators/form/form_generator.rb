# frozen_string_literal: true

require 'rails/generators/base'

class FormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: [], banner: 'attribute attribute'

  def create_form_file
    template 'form.rb.tt', File.join('app', 'forms', class_path, "#{file_name}_form.rb")
  end

  private

  def attributes_properties
    attributes.map do |attribute|
      attribute.split(':').take(2)
               .map { |a| a.to_sym.inspect }.join(', ')
    end
  end
end
