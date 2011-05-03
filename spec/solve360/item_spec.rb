require File.join(File.dirname(__FILE__), "..", "spec_helper")

class Person
  include Solve360::Item
  
  map_fields do
    { "Job Title" => "job_title", "Name" => "name" }
  end
  
  map_categories do
    { "Basic Category" => "basecat" }
  end
end

describe "A Solve360 model" do
  it "should determine model name" do
    Person.resource_name.should == "people"
  end
  
  context "more than one model" do
    it "should not pollute map" do
      class Car
        include Solve360::Item
        map_fields do
          { "Doors" => "doors" }
        end
      end
      
      Car.field_mapping.keys.include?("Doors").should be_true
      Car.field_mapping.keys.include?("Job Title").should be_false
      Person.field_mapping.keys.include?("Doors").should be_false
    end
  end
  
  context "JSON respresentation" do
    before do
      @person = Person.new(:fields => {"Name" => "Stephen"})
      @person.add_related_item({"name" => "Curve21", "id" => "12345"})
      @person.add_category("cat12345")
      
      @json = JSON.parse(@person.to_request)
    end
    
    it "should contain related items to add" do
      @json["relateditems"]["add"][0]["id"].should == "12345"
    end
    
    it "should contain categories to add" do
      @json["categories"]["add"][0].should == "cat12345"
    end
    
    it "should contain item fields" do
      @json["name"].should == "Stephen"
    end
    
  end
end

describe "Field mapping" do
  before do
    Person.map_fields do 
      {"Interests"	=> "custom_interests",
      "Department Website" => "custom_deptwebsite",
      "Description" => "custom_description"}
    end
    
    @person = Person.new
  end
  
  it "should set base map" do
    Person.field_mapping["Job Title"].should == "job_title"
  end
  
  it "should set custom map" do
    Person.field_mapping["Interests"].should == "custom_interests"
  end
  
  it "should allow setting of values on an instance via field maps" do
    @person.fields["Interests"] = "Coding"
    @person.fields["Interests"].should == "Coding"
  end
  
  it "should map human fields to API fields" do
    fields = {"Description" => "A description"}
    
    Person.map_human_fields(fields)["custom_description"].should == "A description"
  end
  
  it "should map API fields to human fields" do
    fields = {:custom_description => "A description"}
    
    Person.map_api_fields(fields)["Description"].should == "A description"
  end
end

describe "Category mapping" do
  before do
    Person.map_categories do
      {
        "First Category" => "cat1",
        "Second Category" => "cat2",
        "And one more just for fun" => "cat3"
      }
    end
    
    @person = Person.new
  end
  
  it "should set base map" do
    Person.category_mapping["Basic Category"].should == "basecat"
  end
  
  it "should set custom map" do
    Person.category_mapping["First Category"].should == "cat1"
  end
  
  it "should map human fields to correct category value" do
    fields = {"Description" => "A description"}
    
    Person.map_category("And one more just for fun").should == "cat3"
  end
end

describe "Creating a record" do
  context "directly from create" do
    before do
      stub_http_response_with("contacts/create-success.json")
      @contact = Solve360::Contact.create(:fields => {"First Name" => "Catherine"})
    end
  
    it "should be valid" do
      @contact.fields["First Name"].should == "Catherine"
      @contact.id.should == "12345"
    end
  end
  
  context "creating a new object then saving" do
    before do
      stub_http_response_with("contacts/create-success.json")
      @contact = Solve360::Contact.new(:fields => {"First Name" => "Catherine"})
      @contact.save
    end
    
    it "should be valid" do
      @contact.id.should == "12345"
    end
  end
  
  context "specifying ownership" do
    before do
      stub_http_response_with("contacts/create-success.json")
      @contact = Solve360::Contact.new(:fields => {"First Name" => "Catherine"})
      @contact.ownership = "12345"
      @contact.save
    end
    
    it "should have assigned a default ownership" do
      @contact.ownership.should == "12345"
    end
    
    it "should contain ownership in any requests" do
      @contact.to_request.should match(/\"ownership\":\"12345\"/)
    end
  end
  
  context "default ownership" do
    before do
      stub_http_response_with("contacts/create-success.json")
      @contact = Solve360::Contact.new(:fields => {"First Name" => "Catherine"})
      @contact.save
    end
    
    it "should have assigned a default ownership" do
      @contact.ownership.should == Solve360::Config.config.default_ownership
    end
    
    it "should contain ownership in any requests" do
      @contact.to_request.should match(/\"ownership\":\"#{Solve360::Config.config.default_ownership}\"/)
    end
  end
end

describe "Finding a record" do
  context "Successfully" do
    before do
      stub_http_response_with("contacts/find-success.json")
      @contact = Solve360::Contact.find(12345)
    end
  
    it "should find existing user" do
      @contact.fields["First Name"].should == "Henry"
      @contact.id.should == "12345"
    end
    
    it "should have relations" do
      @contact.related_items.first["name"].should == "Curve21"
    end
    
    it "should have ownership" do
      @contact.ownership.should == "536663"
    end
  end
end

describe "Updating a record" do
  before do
    @contact = Solve360::Contact.new(:fields => {"First Name" => "Steve"})

    @contact.id = "12345"
    
    stub_http_response_with("contacts/update-success.json")
    
    @contact.fields["First Name"] = "Steve"
    
    @response = @contact.save
  end
  
  it "should be valid" do
    @response["response"]["status"].should == "success"
  end
end

describe "Adding a releated item" do
  before do 
    @contact = Solve360::Contact.new(:fields => {"First Name" => "Steve"})
    @contact.id = "12345"
    
    stub_http_response_with("contacts/update-success.json")
    
    @contact.add_related_item({"name" => "A New Company", "id" => "932334"})
    @contact.save
  end
  
  it "should become set after save" do
    @contact.related_items.first["name"].should == "A New Company"
  end
end

describe "Finding all records" do
  before do
    stub_http_response_with("contacts/find-all.json")
    @contacts = Solve360::Contact.find(:all)
  end
  
  it "should contain all contacts" do
    @contacts.size.should == 2
    first = @contacts.first
    first.class.should == Solve360::Contact
    first.fields["First Name"].should == "Aaron"
    first.fields["Last Name"].should == "Baileys"
  end
end

describe "Handling errors" do
  before do 
    stub_http_response_with("contacts/save-failed.json")
    @contact = Solve360::Contact.new(:fields => {"First Name" => "Steve"})
  end
  
  it "should be invalid" do
    lambda {
      @contact.save
    }.should raise_error(Solve360::SaveFailure)
  end
end

describe "CGI Converting values" do
  it "should convert html entities" do
    @contact = Solve360::Contact.new(:fields => {"First Name" => "Steve & Cat", "Last Name" => 29})
    @contact.to_request.should match(/\"Steve & Cat\"/)
    @contact.to_request.should match(/29/)
  end
end

describe "Debugging" do
  before do
    Solve360.debug
  end
  
  it "should enable debugging on all requests" do
    Solve360::Contact.default_options[:debug_output].should_not be_nil
  end
end