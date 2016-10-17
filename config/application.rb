require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SecretSanta
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    config.autoload_paths << Rails.root.join('lib')

    config.should_seed_application_data = false
    config.should_show_easy_login = false

    config.time_zone = "Australia/Perth"

    config.responders.flash_keys = [ :success, :danger ]
    config.serve_static_assets = true
  end
end
