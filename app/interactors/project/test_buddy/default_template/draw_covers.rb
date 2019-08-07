module Project
  module TestBuddy
    module DefaultTemplate
      class DrawCovers < ::DrawCovers
        ## Const.
        REQUIRED_FIELDS = [
          'title',
          'teams' =>
            [ 'name', 'score', 'total' => ['won', 'lost' => 'today']]
        ]

        ## Etc.
        private

          def setup_context
            assing_partner_attrs_by(self.class.to_s)

            super
          end

          def assing_partner_attrs_by(class_name_string)
            attrs = class_name_string.split('::')

            context.partner_name = attrs[1]
            context.template_name = attrs[2].to_s.gsub('Template', '')
            context.content = context['content']
          end

          def validate
            check_content_requirements

            super
          end

          def check_content_requirements
            content = context.content

            context.fail! message: :content unless content.is_a?(Array)

            REQUIRED_FIELDS.each do |field|
              if field.is_a? String
                content_item = content.find { |ci| ci[field] }

                context.fail! message: "content_#{field}" unless content_item
              elsif field.is_a? Hash
                check_content_existence_by(field, context.content)
              end
            end
          end

          def check_content_existence_by(item, content)
            item.each do |key, value|
              content = find_current_content_scope_by(content, key)
              if value.is_a? String
                context.fail! message: "exists_#{value}" unless content[value]
              elsif value.is_a? Array
                proccess_array_value(value, content)
              end
            end
          end

          def proccess_array_value(value, content)
            grab_requirement_value_list_on_current_level(value).each do |val|
              case val.class.to_s
              when 'String' then check_current_content_for_string(val, content)
              when 'Hash' then process_current_content_for_hash(val, content)
              else context.fail!(message: "#{__method__}_exception")
              end
            end
          end

          def grab_requirement_value_list_on_current_level(values)
            items = values

            values.each do |value|
              items += value.keys if value.is_a? Hash
            end

            items.sort_by { |h| h.is_a?(String) ? 0 : 1 }
          end

          def process_current_content_for_hash(value, content)
            content = [content] if content.is_a? Hash

            content.each do |item|
              check_content_existence_by(value, item)
            end
          end

          def check_current_content_for_string(value, content)
            content = [content] if content.is_a? Hash

            content.each do |item|
              context.fail! message: "exists_#{value}" unless item[value]
            end
          end

          def find_current_content_scope_by(content, key)
            if content.is_a? Array
              content = extract_content_item_by(content, key)
            elsif  content.is_a? Hash
              content = content[key]
            else
              context.fail! message: "structure_format_#{key}"
            end

            content
          end

          def extract_content_item_by(content, key)
            item = content.find { |item| item[key] }

            context.fail! message: "structure_#{key}" unless item

            item[key]
          end
      end
    end
  end
end
