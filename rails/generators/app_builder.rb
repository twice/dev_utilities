class AppBuilder < Rails::AppBuilder
  def initialize(generator)
    super(generator)

    at_exit do
      postprocess
    end
  end

  def readme
    create_file "README.md", "TODO"
  end

  def test
    gem_group :test, :development do
      gem 'rspec-rails'
      gem 'factory_girl_rails'
    end

    gem_group :test do
      gem 'capybara'
      gem 'database_cleaner'
      gem 'launchy'
    end
  end

  def database_yml
    template "config/databases/postgresql.yml", "config/database.yml"
    comment_lines 'config/database.yml', /username|password/
  end

  def leftovers
    gem_group :development do
      gem 'binding_of_caller'
      gem 'better_errors'
      gem 'quiet_assets'
    end

    @generator.gem 'devise'
    @generator.gem 'simple_form'
    @generator.gem 'annotate'
    @generator.gem 'thin'
    @generator.gem 'pg'
    @generator.gem 'bootstrap-sass'
    @generator.gem 'bootstrap-datepicker-rails'

    comment_lines 'Gemfile', /sqlite/
    remove_file "public/index.html"

    if yes? "Do you want to generate a home controller? (y/n)"
      controller_name = ask(" Supply the home controller name: ").underscore
      generate :controller, "#{controller_name} index"
      route "root to: '#{controller_name}\#index'"
      comment_lines 'config/routes.rb', /get/
    end
  end

  # The last step: postprocess: should occur after bundle install
  def postprocess
    rake 'db:setup'

    generate 'rspec:install'
    generate 'devise:install'
    if yes? "Do you want to generate devise views for customization? (y/n)"
      generate 'devise:views'
    end
    generate 'devise', 'User'

    git :init
  end
end
