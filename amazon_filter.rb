require 'amazon/ecs'
require 'pp'

module Jekyll
  class AmazonResultCache
    def initialize
      @result_cache = {}

      @cache_dir = ".amazon-cache/"
      @options = {
        :associate_tag     => nil,
        :AWS_access_key_id => nil,
        :AWS_secret_key    => nil,
        :response_group    => 'Images,ItemAttributes,ItemIds',
        :country           => 'en',
      }
    end

    @@instance = AmazonResultCache.new

    def self.instance
      @@instance
    end

    def setup(context)
      site = context.registers[:site]

      #cache_dir
      @cache_dir = site.config['amazon_cache_dir'].gsub(/\/$/, '') + '/'  if site.config['amazon_cache_dir']

      #options
      @options[:associate_tag]     = site.config['amazon_associate_tag']
      @options[:AWS_access_key_id] = site.config['amazon_access_key_id']
      @options[:AWS_secret_key]    = site.config['amazon_secret_key']
      @options[:country]           = site.config['amazon_country']
    end

    def item_lookup(asin)
      asin.to_s.strip!
      return @result_cache[asin] if @result_cache.has_key?(asin)
      return @result_cache[asin] = Marshal.load(File.read(@cache_dir + asin)) if File.exist?(@cache_dir + asin)

      Amazon::Ecs.options = @options
      res = Amazon::Ecs.item_lookup(asin)
      res.items.each do |item|
        data = {
          :title => item.get('ItemAttributes/Title').to_s.gsub(/ \[Blu-ray\]/, '').gsub(/ \(Ultimate Edition\)/, ''),
          :item_page_url => item.get('DetailPageURL').to_s,
          :small_image_url => item.get('SmallImage/URL').to_s,
          :medium_image_url => item.get('MediumImage/URL').to_s,
          :large_image_url => item.get('LargeImage/URL').to_s,
        }
        open(@cache_dir + asin, "w"){|f| f.write(Marshal.dump(data))}
        @result_cache[asin] = data
        break
      end
      return @result_cache[asin]
    end

    private_class_method :new
  end

  module Filters
    def amazon_link(text)
      AmazonResultCache.instance.setup(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      title = item[:title]
      '<a href="%s">%s</a>' % [url, title]
    end

    def amazon_small_image(text)
      AmazonResultCache.instance.setup(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:small_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    def amazon_medium_image(text)
      AmazonResultCache.instance.setup(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:medium_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    def amazon_large_image(text)
      AmazonResultCache.instance.setup(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:large_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end
  end
end
