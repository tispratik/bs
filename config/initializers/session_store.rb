# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_launchpad_session',
  :secret      => '7055c443645141952edd88ba943613da2176b7f55b0b1f110ec84da233734e0aa7e06b16b428848b6090699594b50900c4d46d46a44a44c3f185e8dd270b6cf5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
#ActionController::Base.session_store = :active_record_store
