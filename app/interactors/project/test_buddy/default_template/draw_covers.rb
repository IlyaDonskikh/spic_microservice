module Project
  module TestBuddy
    module DefaultTemplate
      class DrawCovers < ::DrawCovers
        ## Const.
        REQUIRED_FIELDS = [
          'title',
          'list' => [ 'text', 'first' ],
          'teams' =>
            [ 'name', 'score', 'total' => ['won', 'lost' => 'today']],
        ].freeze

        ## Etc.
        private

          def setup_context
            assing_partner_attrs_by(self.class.to_s)

            super
          end

          def assing_partner_attrs_by(class_name)
            attrs = class_name.split('::')

            context.partner_name = attrs[1].to_s.to_snakecase
            context.template_name = attrs[2].to_s.gsub('Template', '').to_snakecase
            context.content = context['content']
          end

          def validate
            check_content_requirements

            super
          end

          def check_content_requirements
            content = context.content

            context.fail! message: :content unless content.is_a?(Array)

            tag = 'content'

            check_content_existence_by(
              { tag => REQUIRED_FIELDS },
              { tag => context.content }
            )
          end

          ## BEGIN. Recursion content check up
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
