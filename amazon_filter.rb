require 'amazon/ecs'

module Jekyll
  class AmazonResultCache
    def initialize
      @cache_dir = ".amazon-cache/"
      @result_cache = {}
    end

    @@instance = AmazonResultCache.new

    def self.instance
      @@instance
    end

    def set_site(context)
      @site = context.registers[:site]
    end

    def item_lookup(asin)
      asin.to_s.strip!
      return @result_cache[asin] if @result_cache.has_key?(asin)
      return @result_cache[asin] = Marshal.load(File.read(@site.config['amazon_cache_dir'] + asin)) if File.exist?(@site.config['amazon_cache_dir'] + asin)

      Amazon::Ecs.options = {
        :associate_tag => @site.config['amazon_associate'],
        :AWS_access_key_id => @site.config['amazon_key_id'],
        :AWS_secret_key => @site.config['amazon_secret_key_id'],
        :response_group => 'Images,ItemAttributes,ItemIds',
        :country => @site.config['amazon_locale'],
      }

      res = Amazon::Ecs.item_lookup(asin)
      res.items.each do |item|
        data = {
          :title => item.get('ItemAttributes/Title').to_s.gsub(/ \[Blu-ray\]/, '').gsub(/ \(Ultimate Edition\)/, ''),
          :item_page_url => item.get('DetailPageURL').to_s,
          :small_image_url => item.get('SmallImage/URL').to_s,
          :medium_image_url => item.get('MediumImage/URL').to_s,
          :large_image_url => item.get('LargeImage/URL').to_s,
        }
        open(@site.config['amazon_cache_dir'] + asin, "w"){|f| f.write(Marshal.dump(data))}
        @result_cache[asin] = data
        break
      end
      return @result_cache[asin]
    end

    private_class_method :new
  end

  module Filters
    def amazon_link(text)
      AmazonResultCache.instance.set_site(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      title = item[:title]
      '<a href="%s">%s</a>' % [url, title]
    end

    #def amazon_authors(text)
    #  #resp = AmazonResultCache.instance.item_lookup(text)
    #  #item = resp.item_lookup_response[0].items[0].item[0]
    #  item = AmazonResultCache.instance.item_lookup(text)
    #  authors = item.item_attributes.author.collect(&:to_s)
    #  array_to_sentence_string(authors)
    #end

    def amazon_medium_image(text)
      AmazonResultCache.instance.set_site(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:medium_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    def amazon_large_image(text)
      AmazonResultCache.instance.set_site(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:large_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    def amazon_small_image(text)
      AmazonResultCache.instance.set_site(@context)
      item = AmazonResultCache.instance.item_lookup(text)
      url = item[:item_page_url]
      image_url = item[:small_image_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    #def amazon_release_date(text)
    #  #resp = AmazonResultCache.instance.item_lookup(text)
    #  #item = resp.item_lookup_response[0].items[0].item[0]
    #  item = AmazonResultCache.instance.item_lookup(text)
    #  item.item_attributes.theatrical_release_date.to_s
    #end

    ## Movie specific
    #def amazon_actors(text)
    #  #resp = AmazonResultCache.instance.item_lookup(text)
    #  #item = resp.item_lookup_response[0].items[0].item[0]
    #  item = AmazonResultCache.instance.item_lookup(text)
    #  actors = item.item_attributes.actor.collect(&:to_s)
    #  array_to_sentence_string(actors)
    #end

    #def amazon_director(text)
    #  #resp = AmazonResultCache.instance.item_lookup(text)
    #  #item = resp.item_lookup_response[0].items[0].item[0]
    #  item = AmazonResultCache.instance.item_lookup(text)
    #  item.item_attributes.director.to_s
    #end

    #def amazon_running_time(text)
    #  #resp = AmazonResultCache.instance.item_lookup(text)
    #  #item = resp.item_lookup_response[0].items[0].item[0]
    #  item = AmazonResultCache.instance.item_lookup(text)
    #  item.item_attributes.running_time.to_s + " minutes"
    #end

  end
end

