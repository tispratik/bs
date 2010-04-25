require 'test_helper'

class ManageProjectsTest < ActionController::IntegrationTest

  context "user" do
    setup do
      login_user
      @project = @current_user.projects.make
    end
    
    should "create project" do
      visit new_project_path
      within "form#new_project" do
        fill_in "Name", :with => "Project Name"
        fill_in "Permalink", :with => "testproject"
        select "Open", :from => "Status"
        click_button "project_submit"
      end
    end
    
    should "update project" do
      visit edit_polymorphic_path(@project)
      fill_in "project_name", :with => "New Project Name"
      click_button "project_submit"
      assert page.has_content?("New Project Name")
    end
  end
  
end
