# CruftTracker
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'cruft_tracker'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install cruft_tracker
```

## Developing

A Docker / docker-compose environment is available to simplify development and is recommended. Assuming you already have Docker installed, you can spin up MySQL and open a bash console on a container with Ruby installed like this:

```bash
docker-compose run --rm ruby bash
```

The MySQL server has its port exposed as 13306. Note that the first time you spin up these containers it may take a moment for mysql to successfully spin up.

The gem's source is mapped to `/app`, which is also the working directory.

Once you have a bash console open, you can install dependencies with:

```bash
bundle install
bundle exec appraisal install
```

You can copy the provided MySQL DB config file to be the one to use in the test app:

```bash
cp spec/dummy_app/config/database.mysql.yml spec/dummy_app/config/database.yml
```

And now you should be able to run any command against whichever version of Rails you wish (5.2, 6.0, or 6.1), like so:

```bash
bundle exec appraisal rails-6.1 <some command>
```

For example:

```bash
# open a Rails 5.2 console
bundle exec appraisal rails-5.2 rails c

# run a rake task with rails-6.0
bundle exec appraisal rails-6.0 rake <some task>

# run tests
bundle exec appraisal rails-6.1 rspec spec
```

### Running the dummy app

You can run the dummy app with docker-compose like so:

```
rm tmp/pids/server.pid
docker-compose stop ruby
RAILS_VERSION=6.1 docker-compose up -d ruby
docker attach cruft_tracker_ruby_1
```

The `RAILS_VERSION` environment variable is required. Options are: 5.2, 6.0, or 6.1. This will run the application on port 3000 and it can be accessed in your browser at http://localhost:3000. You should be able to use `binding.pry` for debugging.

### Running tests

Tests can be run from a Docker bash console like this:



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dhughes/is_this_used.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
