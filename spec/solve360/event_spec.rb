require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "the Event model" do
  it "should determine model name" do
    Solve360::Event.resource_name.should == "contacts/event"
  end
end