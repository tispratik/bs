class UserSession < Authlogic::Session::Base
  logout_on_timeout false # default if false
  find_by_login_method :find_by_username_or_login_email
  
  def to_key
   new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
  
end