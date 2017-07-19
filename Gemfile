source 'https://rubygems.org'
ruby '2.4.1'

gem 'rails', '4.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#postgresql
gem 'pg', '0.20'
#server
gem 'thin'

#authorization/authentication
gem 'devise'
gem 'cancancan', '~> 1.10'

# WYSIWYG provided by tinymce DON'T UPDATE css will be lost.
gem 'tinymce-rails'
# gem 'tinymce-rails-imageupload', '~> 3.5.6.3'


# for file upload and storage
gem 'carrierwave'
gem 'rmagick'
gem 'fog'
gem 'carrierwave_direct'
gem 'sidekiq'
gem 'panda', '~> 1.6.0'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# for enhancing forms
gem 'inherited_resources'
gem 'dynamic_form'

# for heroku
gem 'mandrill-api'
gem 'newrelic_rpm'
gem 'rails_12factor'

# for LTI
gem 'ims-lti'
gem 'oauth'

# for caching
gem 'canvas-api'
gem 'memcachier'
gem 'dalli'

# for profiling Must be after pg gem
gem 'rack-mini-profiler'

# for a jammin' console
gem 'pry'
gem 'pry-nav'
gem 'pry-doc'
gem 'pry-rails'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.0', require: false, group: :development
gem 'capistrano-rvm'

gem 'test-unit', '~> 3.0'

# For Kaltura uploads
gem 'kaltura-client', '1.0', :path => 'vendor/gems/kaltura'
gem 'rest-client'
gem 'shoulda'

gem 'haml'

gem 'protected_attributes'

# Gems used only for assets and not required
# in production environments by default.
group :development do
  gem 'awesome_print'
  gem 'ruby-prof'
  gem 'rails_best_practices'
  gem 'foreigner'
  gem 'immigrant'
  # gem 'debugger'  wasn't working with ruby 2.0.0-p647
  gem 'hirb'
  gem 'jist'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-passenger'  
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
# adding 2.0.3 declaration may fix capybara-webkit issues
# per: http://stackoverflow.com/questions/15996969/capybara-webkit-page-should-have-content-not-implemented
  gem "capybara", "2.0.3"
 # gem "capybara-webkit"
  gem "guard-rspec"
  gem "launchy"
  gem 'cucumber-rails', :require => false
  gem "database_cleaner"
  gem 'guard-cucumber'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rb-fsevent', '~> 0.9.1'
end

gem 'sass-rails',   '~> 4.0'
gem 'coffee-rails', '~> 4.0'
gem 'twitter-bootstrap-rails', '2.2.8'
gem 'less-rails'
gem 'font-awesome-rails'
gem 'therubyracer', :platforms => :ruby
gem 'uglifier', '>= 1.0.3'
gem 'toastr-rails'
