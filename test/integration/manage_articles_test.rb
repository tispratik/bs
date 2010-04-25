require 'test_helper'

class ManageArticlesTest < ActionController::IntegrationTest

  context "user" do
    setup do
      login_user
      @project = @current_user.projects.make
      @article = @project.articles.make(:user => @current_user)
    end
    
    should "create article" do
      visit new_polymorphic_path([@project, :article])
      within "form#new_article" do
        fill_in "Title", :with => "Test Article"
        fill_in "Content", :with => "Article content"
        fill_in "Add Attachment", :with => "public/images/rails.png"
        click_button "article_submit"
      end
      assert page.has_content?("Article was created.")
    end
    
    should "update article" do
      visit edit_polymorphic_path([@project, @article])
      fill_in "article_title", :with => "New Article Title"
      fill_in "article_content", :with => "Article Content"
      fill_in "Add Attachment", :with => "public/images/rails.png"
      click_button "article_submit"
      assert page.has_content?("New Article Title")
    end
    
  end

end