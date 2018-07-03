require 'rails_admin/config/fields/base'

module RailsAdmin
  module Config
    module Fields
      module Types
        class JsonTranslateCKEditor < RailsAdmin::Config::Fields::Types::Text
          RailsAdmin::Config::Fields::Types.register(:json_translate_ck_editor, self)

          # If you want to have a different toolbar configuration for CKEditor
          # create your own custom config.js and override this configuration
          register_instance_option :config_js do
            nil
          end

          # Use this if you want to point to a cloud instances of CKeditor
          register_instance_option :location do
            nil
          end

          # Use this if you want to point to a cloud instances of the base CKeditor
          register_instance_option :base_location do
            "#{Rails.application.config.assets.prefix}/ckeditor/"
          end

          register_instance_option :partial do
            :form_json_translate_ck_editor
          end

          [:base_location, :config_js, :location].each do |key|
            register_deprecated_instance_option :"ckeditor_#{key}", key
          end

          register_instance_option :pretty_value do
            value_for_locale(current_locale)
          end

          register_instance_option :locales do
            I18n.available_locales
          end

          def parse_value(value)
            begin
              json = JSON.parse(value)
            rescue => exception
              json = JSON.generate("#{I18n.locale}" => value)
            end
            json
          end

          def parse_input(params)
            params[name] = parse_value(params[name]) if params[name].is_a?(::String)
          end

          def value_for_locale(locale)
            val = @bindings[:object].send(name)
            return '' unless val

            val = JSON.parse(val) unless val.is_a?(Hash)
            val.try(:[], locale.to_s)
          rescue JSON::ParserError
            ''
          end

          def current_locale
            value_for_locale(I18n.locale).blank? ? locales.first : I18n.locale
          end
        end
      end
    end
  end
end