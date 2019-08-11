module Project
  module TestBuddy
    module DefaultTemplate
      class DrawCover < ::DrawCover
        ## Const.
        REQUIRED_FIELDS = [
          'title',
          'tagline',
          'background_url',
          'info' => [{ 'core_gems' => %w(title text) }, { 'github_address' => %w(title text) }],
          'author' => %w(firstname lastname)
        ].freeze

        ## Etc.
        private

          def extend_context
            assing_project_attrs_by_class_name

            super
          end

          def validate
            check_content_requirements

            super
          end

          def check_content_requirements
            content = context.template_body

            context.fail! message: :template_body unless content.is_a?(Hash)

            tag = 'content'

            check_content_existence_by(
              { tag => REQUIRED_FIELDS },
              { tag => content }
            )
          end

          ## BEGIN. Recursion content check up
          #  !REFACTOR by https://dry-rb.org/gems/dry-schema/nested-data/
          def check_content_existence_by(item, content)
            item.each do |key, value|
              current_content = find_current_content_scope_by(content, key)

              if value.is_a? String
                check_current_content_for_string(value, current_content)
              elsif value.is_a? Array
                proccess_array_value(value, current_content)
              end
            end
          end

          def proccess_array_value(value, content)
            grab_requirement_value_list_on_current_level_by(value).each do |val|
              case val.class.to_s
              when 'String' then check_current_content_for_string(val, content)
              when 'Hash' then process_current_content_for_hash(val, content)
              else context.fail!(message: "#{__method__}_exception")
              end
            end
          end

          def grab_requirement_value_list_on_current_level_by(values)
            items = values

            values.each do |value|
              items += value.keys if value.is_a? Hash
            end

            items.sort_by { |h| h.is_a?(String) ? 0 : 1 }
          end

          def process_current_content_for_hash(value, content)
            content = [content] if content.is_a? Hash

            content.each { |item| check_content_existence_by(value, item) }
          end

          def check_current_content_for_string(value, content)
            content = [content] if content.is_a? Hash

            content.each do |item|
              context.fail! message: "exists_#{value}" unless item[value]
            end
          end

          def find_current_content_scope_by(content, key)
            content = content.find { |item| item[key] } if content.is_a?(Array)

            if content.is_a? Hash
              content = content[key]
            else
              context.fail! message: "structure_format_#{key}"
            end

            content
          end
          ## END. Recursion content check up
      end
    end
  end
end
