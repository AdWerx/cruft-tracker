# CruftTracker

Have you ever asked yourself, "Is this method even being used?!" Or, "What the heck is this method receiving?" Does your application use Rails? If the answers
these questions are yes, this gem may be of use to you!

Large applications can accrue cruft; old methods that might once have been important, but are now unused or code that is difficult to understand, but dangerous to refactor. Unfortunately,
software is _complex_ and sometimes it's unclear what's really going on. This adds maintenance burdens, headaches, and uncertainty.

This gem aims to give you a couple tools to make it easier to know what (and how) your code is being used (or not).

CruftTracker supports Rails versions 5.2 to 6.1 at this time. As of now the gem only supports MySQL, but contributions for Postgres or other DBMS would be welcome.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'cruft_tracker'
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install cruft_tracker
```

You'll need to create the migrations to add the required tables to your database:

```bash
bin/rails cruft_tracker:install:migrations
```

After that, you can run migrations as you normally would. If you've previously installed this gem and are updating it, you may need to install any new or updated migrations. Just run the command above again when you upgrade to ensure you get the latest migrations.

## Usage

### Tracking method invocations

CruftTracker is pretty simple. Let's say you have a class (or module) like this...

```ruby
class SomeOldClass
  def some_old_method
    # do things
  end
end
```

You're unsure if the `some_old_method` method is actually being used. All you need to do is use `CruftTracker.is_this_method_used?`. This method requires you to pass `self` and a symbol to identify the name of the method to track. For example:

```ruby
class SomeOldClass
  def some_old_method
    # do things
  end

  CruftTracker.is_this_method_used? self, :some_old_method
end
```

What do you get out of this? Well, as soon as Ruby loads the `SomeOldClass` class, CruftTracker will create a new record
in the `cruft_tracker_methods` table that looks like this:


| id  | owner        | name            | method_type     | invocations | comment | deleted_at | created_at          | updated_at          |
| --- | ------------ | --------------- | --------------- | ----------- | ------- | ---------- | ------------------- | ------------------- |
| 1   | SomeOldClass | some_old_method | instance_method | 0           | null    | null       | 2022-01-21 14:07:48 | 2022-01-21 14:07:48 |

This record is accessible using the `CruftTracker::Method` model. EG: `CruftTracker::Method.find(1)`

The fields are:

- `id` - Shockingly, this is the primary key.
- `owner` - This is the name of the Ruby class or module that owns the method.
- `name` - This is the name of the method.
- `method_type` - This is either "instance_method" or "class_method", which are the values of the corresponding
  constants, `CruftTracker::Method::INSTANCE_METHOD` and `CruftTracker::Method::CLASS_METHOD`.
- `invocations` - The number of times the method has been invoked.
- `comments` -  This is a JSON field containing extra data provided to the option `comments:` argument for the `is_this_method_used?` method.
- `deleted_at` - When set, this indicates that the method is no longer being tracked.
- `created_at` - The date/time we started tracking the method.
- `updated_at` - The last time this record was updated. IE: the last time the tracked method was invoked.

Looking at this, we can see that the `some_old_method` method has never been invoked. This is nice because it means that
you can track uses of methods without changing their behavior and also know when a method has _not_ been used. A similar record is created for every method you annotate
with `CruftTracker.is_this_method_used?`.

Assuming your production application eagerly loads classes, you should always have records for potentially crufty
methods, even if the class itself is never explicitly used.

So, having annotated the method, you can check this table after a while. If you see that there have been zero invocations,
you have a reasonably good hint that the method may not actually be used. Of course, you should consider that there are
some processes that are not run frequently at all, so this gem isn't a panacea. **Think before you delete!**

`CruftTracker.is_this_method_used?` can be used to track any kind of method (except `initialize`) with any visibility. This includes class and module methods (`self.`), private class methods, eigenclass methods, as well as public, private, and protected instance methods.

### Comments

Since you may have to track a method for a while, it might be helpful to have a reminder as to _why_ you're tracking it in the first place. This can be recorded by providing an optional `comments:` named argument. For example:

```ruby
class SomeOldClass
  def some_old_method
    # do things
  end

  CruftTracker.is_this_method_used?
    self,
    :some_old_method,
    comment: "I suspect this method is being called via metaprogramming."
end
```

`comment:` can be anything that can be serialized to JSON. For example:

```ruby
class SomeOldClass
  def some_old_method
    # do things
  end

  CruftTracker.is_this_method_used?
    self,
    :some_old_method,
    comment: {
      creator: "Doug Hughes",
      note: "Found while working on marketing code. I suspect this method is unused."
    }
end
```

The comment is serialized to json and stored in the `comments` field of the `CruftTracker::Method` record.

### Tracking Backtraces / Stacktraces

By default, CruftTracker will record unique backtraces for each invocation of a tracked method. This data is stored in the `cruft_tracker_backtraces` table and is accessible via the `CruftTracker::Method`'s `backtraces` association. The `cruft_tracker_backtraces` table has the following columns:

- `id` - Ye olde primary key.
- `traceable_type` - The type for the polymorphic `traceable` association. Future versions of CruftTracker may track data in addition to method invocations.
- `traceable_id` - The ID of the polymorphic `traceable` association. EG: the `CruftTracker::Method` the backtrace is recorded for.
- `trace_hash` - Traces are stored as JSON. This column is an MD5 hash of the trace that is indexed to make it easier / faster to know if we've seen a particular trace before.
- `trace` - The trace data, stored as a JSON array of hashes.
- `occurrences` - This is the number of times we've seen a particular backtrace.
- `created_at` - The first time we saw a particular backtrace.
- `updated_at` - The most recent time we saw a particular backtrace.

Backtraces can be referenced to figure out exactly where a tracked method is being used. It also implicitly tells you other code that is definitely being used. Do note that as code changes, these record backtraces are not updated. So, if a backtrace says the tracked method was invoked from line 123 of some file, if that file is edited, the line numbers may no longer match. Also, this would be record as a new backtrace.

Future versions of CruftTracker may provide a UI for exploring backtraces.

### Tracking Arguments

You can optionally track details about arguments provided to tracked methods. This is done via a proc passed to the the `CruftTracker::Method`'s optional `track_arguments:` argument. For example, let's say you have the following method and that it has no test coverage:

```ruby
class SomeClass
  def do_something_via_metaprogramming(options)
    options[:target_class].constantize.send(options[:method], options[:modifiers])
    YetAnotherClass.do_something_else(options)
  end
end
```

Take a moment and read that glorious mess. When you're done feeling queasy, read on:

Assuming `do_something_via_metaprogramming` is being used at all, we know:

- It calls an arbitrary method (specified via `options[:method]`) on an arbitrary class (specified via `options[:target_class]`) and passes an unknown argument to it (`options[:modifiers]`).
- It passes `options` to `YetAnotherClass.do_something_else`.
- `options` is _probably_ a hash.

Here's what we don't know:

- We have no idea what classes might receive whatever method is being invoked.
- We don't know what method is being invoked.
- We don't know what's being passed to that method.
- We don't know anything about the structure of `options` at all, so we don't know what's being passed to `YetAnotherClass.do_something_else`.

Now, I ask you a few questions:

1. Can we safely delete `SomeClass#do_something_via_metaprogramming`?
2. What options does `do_something_via_metaprogramming` receive? Are they always the same options?
3. What classes and methods does `do_something_via_metaprogramming` invoke via metaprogramming?

The answer: _Who the heck knows?!_ 🤷

So, let's start collecting some data about these arguments. We can do this with the `track_arguments:` named argument on `is_this_method_used?`. This argument takes a proc that receives an `args` array as an argument. Whatever the proc returns is serialized to JSON and stored in the `cruft_tracker_arguments` table.

The naive approach to tracking arguments would be to use something like this:

```ruby
class SomeClass
  def do_something_via_metaprogramming(options)
    options[:target_class].constantize.send(options[:method], options[:modifiers])
    YetAnotherClass.do_something_else(options)
  end

  CruftTracker.is_this_method_used?
    self,
    :do_something_via_metaprogramming,
    track_arguments: -> (args) { args }
end
```

This will track all of the values of the options provided to the `do_something_via_metaprogramming` method. This could be a problem. Consider a case where the method is used a zillion times per day and where there's a plethora of complicated data being passed through the method via its `options` argument. It's possible that each set of arguments is different. This could result in one `potential_cruft_arguments` record per invocation of the tracked method. This is both probably not what. What you probably want to know in this case is:

- What are the unique sets of keys in the `options` hash?
- What classes and methods are we calling via metaprogramming?

We could write a proc that looks like this:

```ruby
class SomeClass
  def do_something_via_metaprogramming(options)
    options[:target_class].constantize.send(options[:method], options[:modifiers])
    YetAnotherClass.do_something_else(options)
  end

  CruftTracker.is_this_method_used?
    self,
    :do_something_via_metaprogramming,
    track_arguments: -> (args) do
      options = args.first

      {
        options_keys: options.keys.sort,
        metaprogramming_target: "#{options[:target_class]}##{options[:method]}"
      }
    end
end
```

So, let's say the method is invoked like this:

```ruby
SomeClass.new.do_something_via_metaprogramming(
  target_class: 'PigLatinTranslator',
  method: 'translate',
  modifiers: {
    change_case: true,
    reverse: false,
    other_data: [:a, "foo", {x: 123}]
  },
  title: 'blargh'
)

SomeClass.new.do_something_via_metaprogramming(
  method: 'send_email',
  target_class: 'MarketingMailer',
  modifiers: {
    recipient: 'foo@bar.com',
    subject: "We'd like to talk to you about your car's warranty.",
    distributor: 'XYZ'
  },
  warranty_data: {
    fake: true,
    lunch_plans: 'Panda Pavilion'
  },
  whatever: 42
)

SomeClass.new.do_something_via_metaprogramming(
  method: 'translate',
  target_class: 'PigLatinTranslator',
  title: 'Old Man and the Sea',
  modifiers: {
    change_case: false,
    other_data: "whatever"
  }
)
```

With the naive approach, we'd have logged three arguments with a ton of data that may or may not be useful. With the second example's `track_arguments:` proc, we'd end up with two records containing this information:

The first record's arguments:

```json
{
  "options_keys": ["method","modifiers","target_class","title"],
  "metaprogramming_target": "PigLatinTranslator#translate"
}
```

The second record's arguments:

```json
{
  "options_keys": ["method","modifiers","target_class","warranty_data","whatever"],
  "metaprogramming_target": "MarketingMailer#send_email"
}
```

Using this approach, you can start to update the `do_something_via_metaprogramming` method to, perhaps, explicitly name the options it accepts, replace metaprogramming with explicit code to make it's clear what classes and methods are being invoked, etc.

Arguments are tracked in the `cruft_tracker_arguments` table which has these columns:

- `id` - An ID. (I bet you did't see that coming!)
- `method_id` - The ID of the method the argument record belongs to.
- `arguments_hash` - Arguments are stored as JSON. This column is an MD5 hash of the arguments that is indexed to make it easier / faster to know if we've seen a particular set of arguments before.
- `arguments` - The transformed argument data, stored as JSON data.
- `occurrences` - This is the number of times we've seen a particular set of arguments.
- `created_at` - The first time we saw a particular set of arguments.
- `updated_at` - The most recent time we saw a particular set of arguments.


### Tracking Everything

So, let's say you've got a class with a bunch of methods. You want to know if any of the methods are being used, and you just don't want to think very hard about it. That's where `CruftTracker.are_any_of_these_methods_being_used?` comes to the rescue! Just tack that onto the end of your class like this to track all method invocations:

```ruby
class SomeClass

  def self.do_something
    # ...
  end

  def jump_up_and_down
    # ...
  end

  private

  def say_hi(to)
    # ...
  end

  # ... other methods ...

  CruftTracker.are_any_of_these_methods_being_used? self
end
```

This will result in a `cruft_tracker_methods` record being created for each method in the `SomeClass` class. It will _not_ track methods that exist in the class' (or module's) ancestors. It's a quick and easy way to see what's being used. This method cannot be used to track arguments, though it does accept a `comments:` named argument.

You may want to think twice about using this method, or using this method too widely as it may create more data than you expect. CruftTracker is lightweight, but too much of a good thing is still too much. Generally, you should favor being targeted in your tracking.

### Clean Up

CruftTacker automatically cleans up after itself. ✨🧹 If you remove an instance of `CruftTracker.is_this_method_used?` to stop tracking a method, CruftTracker will recognize this when your application starts up and mark the associated `cruft_tracker_methods` record as deleted. But, only in environments where eager loading is enabled.

## API Docs

### `CruftTracker` module methods

#### `#is_this_method_used?`

Used to indicate that a particular method should be tracked. Creates a record in the `cruft_tracker_methods` table.

Returns an instance of `CruftTracker::Method`.

##### Arguments

| Name                     | Type                                    | Required? | Default | Description                                                                                                                                                                                                  |
| ------------------------ | --------------------------------------- | --------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| owner (positional)       | a class or module constant              | yes       | N/A     | A reference to the class or module that owns the method. Set this to `self`.                                                                                                                                 |
| name (positional)        | symbol                                  | yes       | N/A     | The name of the method to track in symbol form. Do not include `self.` for class methods, just the name of the method. EG: `:some_method_to_track`.                                                          |
| method_type: (named)     | string                                  | no        | nil     | Used to disambiguate between class and instance methods with the same name.  Must be either `CruftTracker::Method::INSTANCE_METHOD` or `CruftTracker::Method::CLASS_METHOD`.                                 |
| comment: (named)         | anything that can be serialized to json | no        | nil     | Arbitrary data you want to include with the `cruft_tracker_methods` record. For example, a note about why the method is being tracked or a hash with keys indicating who is tracking the method and and why. |
| track_arguments: (named) | a proc                                  | no        | nil     | A proc that accepts `args` and transforms them for logging. (See [Tracking Arguments](#tracking-arguments).)                                                                                                                                                                                                       |

#### `#are_any_of_these_methods_being_used?`

Used to track all methods belonging to the class tagged with this method. This must be used at the end of the class so that all tracked methods are already defined when the class is loaded.

Returns an array of `CruftTracker::Method` instances.

##### Arguments

| Name               | Type                                    | Required? | Default | Description                                                  |
| ------------------ | :-------------------------------------- | --------- | ------- | ------------------------------------------------------------ |
| owner (positional) | a class or module constant              | yes       | N/A     | A reference to the class or module that owns the method. Set this to `self`. |
| comment: (named)   | anything that can be serialized to json | no        | nil     | Arbitrary data you want to include with the `cruft_tracker_methods` record. For example, a note about why the method is being tracked or a hash with keys indicating who is tracking the method and and why. |

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

```bash
rm tmp/pids/server.pid
docker-compose stop ruby
RAILS_VERSION=6.1 docker-compose up -d ruby
docker attach cruft_tracker_ruby_1
```

The `RAILS_VERSION` environment variable is required. Options are: 5.2, 6.0, or 6.1. This will run the application on port 3000 and it can be accessed in your browser at http://localhost:3000. You should be able to use `binding.pry` for debugging.

### Running tests

Tests can be run from a Docker bash console like this:

```bash
bundle exec appraisal rails-5.2 rspec ./spec
```

## Building and Publishing the Gem (because I always forget)

Be sure the bump the version in `CruftTracker::VERSION` before building the gem to publish.

```bash
gem build cruft_tracker.gemspec
```

This will create a new gem file with a name like `cruft_tracker-x.y.z.gem` where `x.y.z` is the version number of the gem.

To publish the new version (specify the correct version number): 

```bash
gem push cruft_tracker-x.y.z.gem
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AdWerx/cruft-tracker.

Contributions should use Prettier to format Ruby code and must have tests covering any new features. All unit tests must pass for all supported versions of Rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
