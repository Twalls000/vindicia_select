require 'nokogiri'
require 'vindicia/connection'

module Vindicia
  class SingleClassBuilder

    def create_vindicia_class(vindicia_class)
      class_name = vindicia_class.name
      attributes = vindicia_class.attributes

      Vindicia.const_set(class_name, Class.new() do
        include ActiveModel::Model
        include ActiveModel::Validations

        self.const_set('ATTRIBUTES',attributes)

        attr_accessor *attributes

        def initialize(attributes={})
          attributes.keys.each do |name|
            is_vindicia_object = attributes[name].is_a?(Hash) && attributes[name][:"@xsi:type"].split(':')[0] =='vin'
            if is_vindicia_object && attributes[name].is_a?(Hash)
              class_name = "Vindicia::#{attributes[name][:"@xsi:type"].split(':')[1]}"
              begin
                send("#{name}=", class_name.constantize.new(attributes[name]))
              rescue
                vindicia_class = Vindicia::Schema.new.classes.select {|class_obj| class_obj.name == class_name.split('::')[1]}.first
                if vindicia_class
                  Vindicia::SingleClassBuilder.new vindicia_class
                  send("#{name}=", class_name.constantize.new(attributes[name]))
                else
                  return gem_original_require(class_name)
                end
              end
            else
              send("#{name}=", attributes[name]) rescue nil
            end

          end
        end
      end)

    end
  end
end
