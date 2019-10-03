# Formation

Form objects for rails build on top Active model and [active_model_attributes](https://github.com/Azdaroth/active_model_attributes)
Heavily inspired by the `rails-patterns` gem. The main difference is that Formation uses `active_model_attributes` instead of `Virtus`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formation

## Usage

```ruby
class ProfileForm < Formation::Form
  # define param_key if no resource is given or if you want the param_key to be diffrent than the resource
  param_key "profile"

  attribute :first_name
  attribute :last_name
  attribute :address1
  attribute :address2

  # you can set default values like so:
  attribute :phone_number, default: '000-000-0000'
  # using a proc
  attribute :last_4, default: Proc.new { |f| f.phone_number[-4..-1] }

  private

  def persist
    resource.update(attributes.except(:address1, :address2))
    resource.address.update(attributes.except(:first_name, :last_name))
  end
end
```

### In your controller

```ruby
# new
def new
  @form = ProfileForm.new(User.new)
end

# create
def create
  @form = ProfileForm.new(User.new, params[:profile])
end

# update
def update
  @form = ProfileForm.new(User.find(params[:id]), params[:profile])
end
```

## Rails Generator

Simply run:
`rails g formation:form optional_namespace/modelname attribute:type`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jwald1/formation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Formation project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/formation/blob/master/CODE_OF_CONDUCT.md).
