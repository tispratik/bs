class ContactsController < ApplicationController
  
  before_filter :login_required, :except => [:get_states_for_country]
  
  def new
    @contactable = find_contactable
    @contact = Contact.new
  end
  
  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end
  
  # POST /contacts
  # POST /contacts.xml
  def create
    @contactable = find_contactable
    @contact = @contactable.build_contact(params[:contact])
    
    respond_to do |format|
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        format.html { redirect_to user_path(@contact.contactable_id) }
      else
        flash[:notice] = 'Failed to create contact.'
        render :action => :new
      end
    end
  end
  
  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])
    @contact.validate_telnum = true
    if @contact.update_attributes(params[:contact])
      flash[:notice] = "Contact details updated!"
    else
      flash[:notice] = @contact.errors.full_messages.join('<br />')
    end
  end
  
  def find_contactable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)         
      end
    end
    nil
  end  
  
  def get_states_for_country
    @states = Region.find_all_by_country_id(params[:country])
    render :partial => 'shared/states_dropdown', :locals => { :states => @states } 
  end
  
end