module Solve360
  class ActivityTemplate
    include Solve360::Item
    
    @template_mapping = {}
    
    map_fields do
      {
        'ID' => 'templateid',
        'Parent' => 'parent'
      }
    end
    
    def self.template(template_name)
      return template_mapping[template_name]
    end
    
    def self.template_mapping
      @template_mapping
    end
    
    def self.map_templates(&block)
      @template_mapping.merge! yield
    end
    
    def self.resource_name
      'contacts/template'
    end
  end
end