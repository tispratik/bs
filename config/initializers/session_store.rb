# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_BS_session',
  :secret      => 'fb802092809dc8ce92a69168eebdbf8b44fa76b8ba33da990d4665c3b48f4b746819412b6b38d370ef6104c6ee3bea784ca5f9a70bb1a5e00121495a56585204'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
