# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gai_srip_session',
  :secret      => '9b1012c7b45db67629a271fa777bc417daf259f0a577e5679d21929b4be27a70cd3c77c2af75de74e70cd8043d133dae41fa4bb8db07233d754c2bf5636cf518'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
