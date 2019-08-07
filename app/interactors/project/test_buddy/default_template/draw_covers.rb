module Project
  module TestBuddy
    module DefaultTemplate
      class DrawCovers < ::DrawCovers
        ## Const.
        REQUIRED_FIELDS = [
          'title',
          'teams' =>
            [ 'name', 'score', 'total' => ['won', 'lost' => ['today']]]
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
            check_content

            super
          end

          def check_content
            content = context.content

            context.fail! message: :content unless content.is_a?(Array)

            REQUIRED_FIELDS.each do |field|
              ## Check if nested field requred (field is Hash) / recursion?

              if field.is_a? String
                content_item = content.find { |ci| ci[field] }

                context.fail! message: "content_#{field}" unless content_item[field]
              elsif field.is_a? Hash
                check_hash_content_existence(field)
              end
            end
          end

          def check_hash_content_existence(item, parents = [])
            item.each do |key, value|
              parents << key
              content = find_current_content_scope_by(context.content, parents)

              parents_log = parents.join('_')

              if value.is_a? String
                context.fail! message: "exists_#{parents_log}_#{value}" unless content[value]
              elsif value.is_a? Array
                value.each do |val|
                  if val.is_a? String
                    if content.is_a? Array
                      content.each do |item|
                        context.fail! message: "exists_#{parents_log}_#{val}" unless item[val]
                      end
                    elsif content.is_a? Hash
                      context.fail! message: "exists_#{parents_log}_#{val}" unless content[val]
                    end
                  elsif val.is_a? Hash
                    check_hash_content_existence(val, parents)
                  end
                end
              elsif value.is_a? Hash?
                check_hash_content_existence(value, parents)
              end
            end
          end

          def find_current_content_scope_by(content, parents = [])
            return content unless parents.any?

            parents_log = parents.join('_')

            parents.each do |parent_name|
              if content.is_a? Array
                content = extract_content_item_by(content, parent_name)
              elsif  content.is_a? Hash
                content = content[parent_name]
              else
                context.fail! message: "structure_format_#{parents_log}_#{parent_name}"
              end
            end

            content
          end

          def extract_content_item_by(content, parent_name)
            item = content.find { |item| item[parent_name] }

            context.fail! message: "structure_#{parents_log}_#{parent_name}" unless item

            item[parent_name]
          end
      end
    end
  end
end
