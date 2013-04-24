# Amazon Plugin for Octopress
This  plugin is inspired [Amazon Liquid Filters for jekyll](http://base0.net/posts/amazon-liquid-filters-for-jekyll/).

## How to install

### Get amazon-ecs

    cd /path/to/octopress

    vi Gemfile

    + gem 'amazon-ecs'

    bundle install --path vendor/bundle

or by gem command

    gem install amazon-ecs


### Get amazon_tab.rb

    cd plugins
    wget https://raw.github.com/longkey1/octopress-amazon-plugin/master/amazon_tag.rb


or by git-submodule

    cd /path/to/octopress
    git submodule add git://github.com/longkey1/octopress-amazon-plugin.git plugins/amazon


### Configuring

    vi /path/to/octopress/_config.yml

    + # Amazon plugin
    + amazon_access_key_id: 'your access key id'
    + amazon_secret_key:    'your secret key'
    + amazon_associate_tag: 'your associate'
    + amazon_cache:         false # or true
    + amazon_cache_dir:     '.amazon-cache'      # default '.amazon-cache'
    + amazon_country:       'jp'                 # default 'en'


## Usage

### Syntax:

    {% amazon [type] [asin] %}

type: text, small_image, medium_image, large_image

### Examples:

    {% amazon large_image 4873113946 %}
