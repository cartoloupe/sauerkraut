# Sauerkraut

Gathers all cucumber step definition source code in one place, in order to refactor cucumber steps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sauerkraut'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sauerkraut

## Usage

On the command line:
`sauerkraut FEATURE_FILE:N[:M] [-o FILE]`

`:N` will gather source code from scenario found at `:N`
`:N:M` will gather source code from the range `N-M` of the feature file
`-o FILE` will output to a file instead of the terminal


## Warnings
When `FEATURE_FILE:N` is a Scenario Outline, it probably won't work yet.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/sauerkraut/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
