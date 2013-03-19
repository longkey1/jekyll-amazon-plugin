# Amazon Plugin for Octopress

## Install

### Install amazon-ecs by bundler

    cd /path/to/octopress

    vi Gemfile

    + gem 'amazon-ecs'

    bundle install --path vendor/bundle


### Install amazon-ecs by bundler

    gem install amazon-ecs


### Download amazon_filter.rb

    cd plugins
    wget https://raw.github.com/longkey1/liquid-amazon-plugin/master/amazon_filter.rb


### Download amazon_filter.rb by git-submodule

    cd /path/to/octopress
    git submodule add git://github.com/longkey1/liquid-amazon-plugin.git plugins/amazon


### Edit _config.yml

    vi /path/to/octopress/_config.yml

    + # Amazon plugin
    + amazon_access_key_id: 'your access key id'
    + amazon_secret_key:    'your secret key'
    + amazon_associate_tag: 'your associate'
    + amazon_cache:         false # or true
    + amazon_cache_dir:     '.amazon-cache'      # default '.amazon-cache'
    + amazon_country:       'jp'                 # default 'en'


## Usage

### Edit post file

    {{ asin | amazon_small_image }}
    {{ asin | amazon_medium_image }}
    {{ asin | amazon_large_image }}
    {{ asin | amazon_long }}
