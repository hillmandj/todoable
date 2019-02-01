# Todoable Gem
This is a gem that wraps an API that's written by the awesome team at Teachable!

Basic auth credentials from Teachable are needed to use this gem. Doing so returns a token that can be used for subsequent requests.
This token expires every 20 minutes, but the gem automatically retrieves a new token should it expire. It does so by leveraging a custom middleware that's plugged into the Faraday client.

## Installation

This gem is not on rubygems and must be built locally!

```bash
gem build todoable.gemspec
gem install todoable-1.0.0.gem
```

If you want to include the gem in IRB you will need to require `todoable`.

```ruby
require 'todoable'
```

## Configuration

In IRB, you can initialize this gem like so:

```ruby
Todoable.configure do |c|
  c.username = 'yourusername'
  c.password = 'yourpassword'
end
```

## Usage

**GET /lists**

Retrieves all lists. The lists in this response _do not_ include todo items.

```ruby
lists = Todoable::List.all
```


**POST /lists**

Creates a list. Currently, the API only supports name

```ruby
list = Todoable::List.new(name: 'My List')
list.create
```


**GET /lists/:list_id**

Retrieve list information. This includes the todo items in the list.

```ruby
list = Todoable::List.find(list_id)
```


**PATCH /lists/:list_id**

Once a list is retrieved, you can update it by altering its attributes (currently only name) like so:

```ruby
list.name = 'New Name'
list.update
```


**DELETE /lists/:list\_id**

Once a list is retrieved, you can delete it like so:

```ruby
list.destroy
```

Alternatively, you can destroy based off identifier

```ruby
Todoable::List.destroy(list_id)
```


**POST /lists/:list\_id/items**

Add an item to a given list. This can be done in two ways

```ruby
list.add_item('Name of Item')

# OR

Todoable::Item.new(list: list, name: 'Name of Item').create
```


**PUT /lists/:list\_id/items/:item\_id/finish**

Marks an item as finished.

If you've fetched a list via `Todoable::List.find` you have access to its items:

```ruby
list = Todoable::List.find(list_id)
item = list.items.first
item.finish!
```


**DELETE /lists/:list\_id/items/:item\_id**

Deletes the item.

```ruby
item.destroy
```


## Testing

Tests can be found in the `spec` directory, and can be run via `rspec`:

```bash
cd path/to/todoable
bundle exec rspec spec
```
