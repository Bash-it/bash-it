# shellcheck shell=bash
about-alias 'pyrocms abbreviations'

###
## PyroCMS 3.4 bash aliases
## @author Denis Efremov <efremov.a.denis@gmail.com>
###

# general
alias a:cl="php artisan clear-compiled" # Remove the compiled class file
alias a:d="php artisan down"            # Put the application into maintenance mode
alias a:e="php artisan env"             # Display the current framework environment
alias a:h="php artisan help"            # Displays help for a command
alias a:i="php artisan install"         # Install the Streams Platform.
alias a:ls="php artisan list"           # Lists commands
alias a:mg="php artisan migrate"        # Run the database migrations
alias a:op="php artisan optimize"       # Optimize the framework for better performance (deprecated)
alias a:pr="php artisan preset"         # Swap the front-end scaffolding for the application
alias a:s="php artisan serve"           # Serve the application on the PHP development server
alias a:u="php artisan up"              # Bring the application out of maintenance mode

# addon
alias a:ad:i="php artisan addon:install"   # Install an addon.
alias a:ad:p="php artisan addon:publish"   # Publish an the configuration and translations for an addon.
alias a:ad:r="php artisan addon:reinstall" # Reinstall an addon.
alias a:ad:u="php artisan addon:uninstall" # Uninstall an addon.

# app
alias a:ap:n="php artisan app:name"    # Set the application namespace
alias a:ap:p="php artisan app:publish" # Publish general application override files.

# assets
alias a:as:cl="php artisan assets:clear" # Clear compiled public assets.

# auth
alias a:au:clrs="php artisan auth:clear-resets" # Flush expired password reset tokens

# cache
alias a:ca:cl="php artisan cache:clear" # Flush the application cache
alias a:ca:f="php artisan cache:forget" # Remove an item from the cache
alias a:ca:t="php artisan cache:table"  # Create a migration for the cache database table

# config
alias a:co:ca="php artisan config:cache" # Create a cache file for faster configuration loading
alias a:co:cl="php artisan config:clear" # Remove the configuration cache file

# db
alias a:db:s="php artisan db:seed" # Seed the database with records

# env
alias a:en:s="php artisan env:set" # Set an environmental value.

# event
alias a:ev:g="php artisan event:generate" # Generate the missing events and listeners based on registration

# extension
alias a:ex:i="php artisan extension:install"   # Install a extension.
alias a:ex:r="php artisan extension:reinstall" # Reinstall a extension.
alias a:ex:u="php artisan extension:uninstall" # Uninstall a extension.

# files
alias a:fi:cl="php artisan files:clean" # Clean missing files from the files table.

# key
alias a:ke:g="php artisan key:generate" # Set the application key

# make
alias a:mk:ad="php artisan make:addon"        # Create a new addon.
alias a:mk:au="php artisan make:auth"         # Scaffold basic login and registration views and routes
alias a:mk:cm="php artisan make:command"      # Create a new Artisan command
alias a:mk:ct="php artisan make:controller"   # Create a new controller class
alias a:mk:ev="php artisan make:event"        # Create a new event class
alias a:mk:fa="php artisan make:factory"      # Create a new model factory
alias a:mk:j="php artisan make:job"           # Create a new job class
alias a:mk:li="php artisan make:listener"     # Create a new event listener class
alias a:mk:ma="php artisan make:mail"         # Create a new email class
alias a:mk:mw="php artisan make:middleware"   # Create a new middleware class
alias a:mk:mg="php artisan make:migration"    # Create a new migration file
alias a:mk:md="php artisan make:model"        # Create a new Eloquent model class
alias a:mk:no="php artisan make:notification" # Create a new notification class
alias a:mk:po="php artisan make:policy"       # Create a new policy class
alias a:mk:pr="php artisan make:provider"     # Create a new service provider class
alias a:mk:rq="php artisan make:request"      # Create a new form request class
alias a:mk:rs="php artisan make:resource"     # Create a new resource
alias a:mk:rl="php artisan make:rule"         # Create a new validation rule
alias a:mk:sd="php artisan make:seeder"       # Create a new seeder class
alias a:mk:st="php artisan make:stream"       # Make a streams entity namespace.
alias a:mk:ts="php artisan make:test"         # Create a new test class

# migrate
alias a:mg:fr="php artisan migrate:fresh"    # Drop all tables and re-run all migrations
alias a:mg:i="php artisan migrate:install"   # Create the migration repository
alias a:mg:rf="php artisan migrate:refresh"  # Reset and re-run all migrations
alias a:mg:rs="php artisan migrate:reset"    # Rollback all database migrations
alias a:mg:rl="php artisan migrate:rollback" # Rollback the last database migration
alias a:mg:st="php artisan migrate:status"   # Show the status of each migration

# module
alias a:mo:i="php artisan module:install"   # Install a module.
alias a:mo:r="php artisan module:reinstall" # Reinstall a module.
alias a:mo:u="php artisan module:uninstall" # Uninstall a module.

# notifications
alias a:no:tb="php artisan notifications:table" # Create a migration for the notifications table

# package
alias a:pk:d="php artisan package:discover" # Rebuild the cached package manifest

# queue
alias a:qu:fa="php artisan queue:failed"       # List all of the failed queue jobs
alias a:qu:ft="php artisan queue:failed-table" # Create a migration for the failed queue jobs database table
alias a:qu:fl="php artisan queue:flush"        # Flush all of the failed queue jobs
alias a:qu:fg="php artisan queue:forget"       # Delete a failed queue job
alias a:qu:li="php artisan queue:listen"       # Listen to a given queue
alias a:qu:rs="php artisan queue:restart"      # Restart queue worker daemons after their current job
alias a:qu:rt="php artisan queue:retry"        # Retry a failed queue job
alias a:qu:tb="php artisan queue:table"        # Create a migration for the queue jobs database table
alias a:qu:w="php artisan queue:work"          # Start processing jobs on the queue as a daemon

# route
alias a:ro:ca="php artisan route:cache" # Create a route cache file for faster route registration
alias a:ro:cl="php artisan route:clear" # Remove the route cache file
alias a:ro:ls="php artisan route:list"  # List all registered routes

# schedule
alias a:sc:r="php artisan schedule:run" # Run the scheduled commands

# scout
alias a:su:fl="php artisan scout:flush"  # Flush all of the model's records from the index
alias a:su:im="php artisan scout:import" # Import the given model into the search index

# session
alias a:se:tb="php artisan session:table" # Create a migration for the session database table

# storage
alias a:sg:l="php artisan storage:link" # Create a symbolic link from "public/storage" to "storage/app/public"

# streams
alias a:st:cl="php artisan streams:cleanup" # Cleanup streams entry models.
alias a:st:co="php artisan streams:compile" # Compile streams entry models.
alias a:st:d="php artisan streams:destroy"  # Destroy a namespace.
alias a:st:p="php artisan streams:publish"  # Publish configuration and translations for streams.
alias a:st:r="php artisan streams:refresh"  # Refresh streams generated components.

# tntsearch
alias a:tn:im="php artisan tntsearch:import" # Import the given model into the search index

# vendor
alias a:ve:p="php artisan vendor:publish" # Publish any publishable assets from vendor packages

# view
alias a:vi:cl="php artisan view:clear" # Clear all compiled view files
