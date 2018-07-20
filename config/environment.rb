# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
# Initialize the rails application
RetroRails::Application.initialize!
require File.expand_path('../initializers/abstract_mysql2_adapter.rb', __FILE__)
