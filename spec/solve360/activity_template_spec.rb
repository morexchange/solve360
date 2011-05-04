require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "the ActivityTemplate model" do
  it "should determine model name" do
    Solve360::ActivityTemplate.resource_name.should == 'contacts/template'
  end
  
  context "mapping template names" do
    before do
      Solve360::ActivityTemplate.map_templates do
        {
          'First Template' => '3445',
          'Second Template' => '4563',
          'Third Template' => '6789',
          'Last Template' => '9565'
        }
      end
    end

    it "should set custom map" do
      Solve360::ActivityTemplate.template_mapping["First Template"].should == "3445"
    end
    
    it "should map human fields to correct template id value" do
      Solve360::ActivityTemplate.template("Third Template").should == "6789"
    end
  end
  
  context "testing" do
    before do
      @actemp = Solve360::ActivityTemplate.new(
        :fields => {'Parent' => '1234'},
        :data => {'ID' => '9876'}
      )
      @json = JSON.parse(@actemp.to_request)
    end
    
    it "should render to_request with data properly inserted" do
      @json["parent"].should == '1234'
      @json["data"]["templateid"].should == '9876' 
    end
  end
end