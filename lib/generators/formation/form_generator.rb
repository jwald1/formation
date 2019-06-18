# frozen_string_literal: true

require 'rails/generators/base'

class Formation::FormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: [], banner: 'attribute attribute'

  def create_form_file
    template 'form.template',
             File.join('app', 'forms', class_path, "#{file_name}_form.rb")
  end

  private

  def attributes_properties
    attributes.map { |a| "#{a.name.to_sym.inspect}, #{a.type.to_sym.inspect}" }
  end
end
