class CommentObserver < ActiveRecord::Observer
  def after_save(comment)
    Emailer.deliver_comment("tispratik@gmail.com", "New comment was posted", "Hi")
  end
  
  def after_destroy(contact)
    contact.logger.warn("Contact with an id of #{contact.id} was destroyed!")
  end
end