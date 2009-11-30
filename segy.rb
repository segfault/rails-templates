# Delete unnecessary files
%w[ README doc/README_FOR_APP public/index.html favicon.ico robots.txt 
  ].each { |f| run "rm #{f}" }

# Set up git repository
git :init

# Copy database.yml for distribution use
run "cp config/database.yml config/database.yml.example"

# Set up .gitignore files
run %{find . -type d -empty | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
coverage/*
log/*.log
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
doc/api
doc/app
config/database.yml
coverage/*
END

                
# pull jquery
run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# pull blueprint
run "curl -L http://github.com/joshuaclayton/blueprint-css/raw/master/blueprint/screen.css > public/stylesheets/screen.css"
run "curl -L http://github.com/joshuaclayton/blueprint-css/raw/master/blueprint/ie.css > public/stylesheets/ie.css"
run "curl -L http://github.com/joshuaclayton/blueprint-css/raw/master/blueprint/print.css > public/stylesheets/print.css"

# Install plugins as git submodules
plugin 'acts_as_taggable_redux', :git => 'git://github.com/geemus/acts_as_taggable_redux.git', :submodule => true
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true
plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true
plugin 'factory_girl', :git => 'git://github.com/thoughtbot/factory_girl.git', :submodule => true
plugin 'quietbacktrace', :git => 'git://github.com/thoughtbot/quietbacktrace.git', :submodule => true
plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :submodule => true

# Install all gems
gem 'RedCloth'
gem 'haml'
gem 'ruby-openid', :lib => 'openid'
gem 'nokogiri'

# Initialize submodules
git :submodule => "init"

rake('gems:install', :sudo => true)

# Set up sessions, RSpec, user model, OpenID, etc, and run migrations
rake('db:sessions:create')
generate("authlogic", "user session")
rake('acts_as_taggable:db:create')
rake('db:migrate')

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "SUCCESS!"
