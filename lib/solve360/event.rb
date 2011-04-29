module Solve360
  class Event
    include Solve360::Item
    
    map_fields do
      {
        "Parent" => "parent",
        "Title" => "title",
        "Start Time" => "timestart",
        "End Time" => "timeend",
        "Details" => "details",
        "Attendees" => "attendees",
        "Event Type" => "eventtype",
        "Priority" => "priority",
        "Reminder Time" => "remindtime"
      }
    end
    
    def self.resource_name
      "contacts/event"
    end
  end
end