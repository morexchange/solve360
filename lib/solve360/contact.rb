module Solve360
  class Contact
    include Solve360::Item
    
    map_fields do 
      {
        "Assigned To" => "assignedto",
        "Background" => "background",
        "Business Address" => "businessaddress",
        "Business Direct" => "businessphonedirect",
        "Business Email" => "businessemail",
        "Business Fax" => "businessfax",
        "Business Main" => "businessphonemain",
        "Cellular" => "cellularphone",
        "Extension" => "businessphoneextension",
        "First Name" => "firstname",
        "Home" => "homephone",
        "Home Address" => "homeaddress",
        "Job Title" => "jobtitle",
        "Last Name" => "lastname",
        "Personal Email" => "personalemail",
        "Related To" => "relatedto",
        "Website" => "website"
      }
    end
    
    def self.resource_name
      self.name.to_s.demodulize.downcase.pluralize
    end
  end
end