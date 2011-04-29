module Solve360
  class ProjectBlog
    include Solve360::Item
  
    map_fields do
      {
        "Assigned To" => "assignedto",
        "Background" => "background",
        "Logo" => "logo",
        "Related To" => "relatedto",
        "Title" => "title"
      }
    end
  
    def self.resource_name
      self.name.to_s.demodulize.downcase.pluralize
    end
  end
end