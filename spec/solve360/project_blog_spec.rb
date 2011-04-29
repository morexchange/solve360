require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "the ProjectBlog model" do
  it "should determine model name" do
    Solve360::ProjectBlog.resource_name.should == "projectblogs"
  end
end