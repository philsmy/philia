<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Philia](#philia)
  - [Basic concepts](#basic-concepts)
    - [Tenants == Organizations with Users / Members](#tenants--organizations-with-users--members)
    - [Tenanted models](#tenanted-models)
    - [Universal models](#universal-models)
    - [Join tables](#join-tables)
  - [Installation](#installation)
  - [Upgrading to Philia from Milia](#upgrading-to-philia-from-milia)
  - [Security / Caution](#security--caution)
  - [Contributing to philia](#contributing-to-philia)
  - [Why Philia](#why-philia)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Philia
Philia is a port of [Milia](https://github.com/jekuno/milia), a multi-tenanting gem for Ruby on Rails applications. Philia supports (and requires) Devise.

## Basic concepts

### Tenants == Organizations with Users / Members
A tenant is an organization with many members (users).
Initially a user creates a new organization (tenant) and becomes its first member (and usually admin).
Then he invites further members who can then login and join the tenant.
Philia ensures that users can only access data of their own tenant (organization).


### Tenanted models
Models which belong to a certain tenant (organization).  
Add <i>acts_as_tenant</i> to the model body to activate tenanting for this model.    
Most of your tables (except for pure join tables, users, and tenants) should be tenanted.
Every record of a tenanted table needs to have a `tenant_id` set. Philia takes care of this.

### Universal models
Models which aren't specific to a tenant (organization) but have system wide relevance.
Add <i>acts_as_universal</i> to the model body to mark them as universal models.  
Universal tables <i>never</i> contain critical user/company information.
The devise user table <i>must</i> be universal and should only contain email, encrypted password, and devise-required data.
All other user data (name, phone, address, etc) should be broken out into a tenanted table called `members` (`Member belongs_to :user`, `User has_one :member`).
The same applies for organization (account or company) information.
A record of a universal table must have `tenant_id` set to nil. Philia takes care of this.

### Join tables
Pure join tables (has_and_belongs_to_many HABTM associations) are neither Universal nor Tenanted.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'philia', github: 'philsmy/philia', branch: 'main'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install philia
```

Build Sample App (have Rails 6 as your default rails)
```
rails new test-philia-app --database=mysql -T
cd test-philia-app  
bundle add devise
rails webpacker:install
echo "gem 'philia', path: '../philia'" >> Gemfile
bundle
rails g philia:install 
rails db:drop db:create db:migrate

```

## Upgrading to Philia from Milia
As this is usually done as part of a Rails5 to Rails6 upgrade there's obviously a TON more you need to do.
But for this specific gem I have found this to work:

* search `Milia`, replace with `Philia` (I do this in all `*.rb` files)
* search `milia`, replace with `philia` (I do this in all `*.rb` files)
* rename `config/initializers/milia.rb` to `config/initializers/philia.rb`

That should get you the bulk of the way there.

## Security / Caution
* Philia designates a default_scope for all models (both universal and tenanted). Rails merges default_scopes if you use multiple default_scope declarations in your model, see [ActiveRecord Docs](http://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope). However by unscoping via [unscoped](http://apidock.com/rails/ActiveRecord/Scoping/Default/ClassMethods/unscoped) you can accidentally remove tenant scoping from records. Therefore we strongly recommend to **NOT USE default_scope** at all.
* Philia uses Thread.current[:tenant_id] to hold the current tenant for the existing Action request in the application.
* SQL statements executed outside the context of ActiveRecord pose a potential danger; the current philia implementation does not extend to the DB connection level and so cannot enforce tenanting at this point.
* The tenant_id of a universal model will always be forced to nil.
* The tenant_id of a tenanted model will be set to the current_tenant of the current_user upon creation.
* HABTM (has_and_belongs_to_many) associations don't have models; they shouldn't have id fields
  (setup as below) nor any field other than the joined references; they don't have a tenant_id field;
  rails will invoke the default_scope of the appropriate joined table which does have a tenant_id field.
* Your code should never try to change or set the `tenant_id` of a record manually.
   * philia will not allow it
   * philia will check for deviance
   * philia will raise exceptions if it's wrong and
   * philia will override it to maintain integrity.
* **You use philia solely at your own risk!** 
  * When working with multi-tenanted applications you handle lots of data of several organizations/companies which means a special responsibility for protecting the data as well. Do in-depth security tests prior to publishing your application.



## Contributing to philia

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so we don't break the feature in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so we can cherry-pick around it.

## Why Philia
My name is Phil.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
