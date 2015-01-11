# Amazon Plugin for Jekyll
This  plugin is inspired [Amazon Liquid Filters for jekyll](http://base0.net/posts/amazon-liquid-filters-for-jekyll/).

## How to install

### Get dependency package

    cd /path/to/jekyll

    vi Gemfile

    + gem 'amazon-ecs'
    + gem 'i18n'

    bundle install --path vendor/bundle

or by gem command

    gem install stringex


### Get amazon_tab.rb

    cd plugins
    wget https://raw.github.com/longkey1/jekyll-amazon-plugin/master/amazon_tag.rb


or by git-submodule

    cd /path/to/jekyll
    git submodule add git://github.com/longkey1/jekyll-amazon-plugin.git _plugins/amazon


### Configuring

    vi /path/to/jekyll/_config.yml

    + # Amazon plugin
    + amazon_access_key_id: 'your access key id'
    + amazon_secret_key:    'your secret key'
    + amazon_associate_tag: 'your associate'
    + amazon_cache:         false # or true
    + amazon_cache_dir:     '.amazon-cache'      # default '.amazon-cache'
    + amazon_country:       'jp'                 # default 'en'
    + amazon_locale:        'ja'                 # default 'en'


## Usage

### Syntax:

    {% amazon [type] [asin] %}

type: text, small_image, medium_image, large_image, title, detail, image

### Usage Examples:

    {% amazon large_image 4873113946 %}
    {% amazon detail 4873113946 %}

### Type detail:

[type] detail display item with object layouted by css.
If you want to use this option move `_amazon_tag.scss` file to `/path/to/jekyll/_sass` directory.

    mv _amazon_tag.scss /path/to/jekyll/sass

    vi main.scss

    + @import "amazon-tag";

    jekyll build
