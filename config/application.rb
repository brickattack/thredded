require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "carrierwave"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require *Rails.groups(:assets) if defined?(Bundler)


module Thredded
  mattr_accessor :themes

  class Application < Rails::Application

    ::Thredded.themes = {}

    # speeding up rails per suggestion here - http://dev.theconversation.edu.au/post/5001465621/how-we-shaved-2-seconds-off-our-rails-start-up-time
    # Thank you to Xavier and Pete!
    config.autoload_paths << Rails.root.join("app").to_s
    config.autoload_paths << Rails.root.join("lib").to_s


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.stylesheets         false
      g.orm                 :active_record
      g.template_engine     :erb
      g.test_framework      :rspec, :fixture => true,
                            :views => false,
                            :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    # Asset Pipeline
    config.assets.enabled = true

    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w(rails)
#   config.action_view.javascript_expansions[:jquery]   = ["jquery", "jquery-ui"]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]
    
    ### Part of a Spork hack. See http://bit.ly/arY19y
    if Rails.env.test?
      initializer :after => :initialize_dependency_mechanism do
        # Work around initializer in railties/lib/rails/application/bootstrap.rb
        ActiveSupport::Dependencies.mechanism = :load
      end
    end
    
#   Rack middlewares to use
#   config.middleware.delete ActionDispatch::Flash
#   config.middleware.insert_before Warden::Manager, ActionDispatch::Flash
#   config.middleware.insert_before ActionDispatch::Flash, Rack::Tidy, 'indent-spaces' => 2
    config.middleware.insert_before Rack::Lock, Refraction
  end
end 

ActionDispatch::Callbacks.after do
  # Reload the factories
  return unless (Rails.env.test?)

  unless Factory.factories.blank? # first init will load factories, this should only run on subsequent reloads
    Factory.factories.clear
    Factory.find_definitions.each do |location|
      Dir["#{location}/**/*.rb"].each { |file| load file }
    end
  end

end

