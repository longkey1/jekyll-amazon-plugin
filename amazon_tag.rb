require 'amazon/ecs'
require 'i18n'

module Jekyll
  class AmazonResultCache
    def initialize
      @result_cache = {}

      @cache = false
      @cache_dir = '.amazon-cache/'
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
      @cache = site.config['amazon_cache'] if site.config['amazon_cache']
      @cache_dir = site.config['amazon_cache_dir'].gsub(/\/$/, '') + '/' if site.config['amazon_cache_dir']
      Dir::mkdir(@cache_dir) if File.exists?(@cache_dir) == false

      #options
      @options[:associate_tag]     = site.config['amazon_associate_tag']
      @options[:AWS_access_key_id] = site.config['amazon_access_key_id']
      @options[:AWS_secret_key]    = site.config['amazon_secret_key']
      @options[:country]           = site.config['amazon_country']

      #i18n
      locale = 'en'
      locale = site.config['amazon_locale'] if site.config['amazon_locale']
      I18n.enforce_available_locales = false
      I18n.locale = locale.to_sym
      I18n.load_path = [File.expand_path(File.dirname(__FILE__)) + "/locale/#{locale}.yml"]
    end

    def item_lookup(asin)
      return @result_cache[asin] if @result_cache.has_key?(asin)
      return @result_cache[asin] = Marshal.load(File.read(@cache_dir + asin)) if @cache && File.exist?(@cache_dir + asin)

      Amazon::Ecs.options = @options

      recnt = 0
      begin
        res = Amazon::Ecs.item_search(asin, search_index: 'All')

      #Liquid Exception HTTP Response: 503 Service Unavailable
      rescue Amazon::RequestError => e
        if /503/ =~ e.message && recnt < 3
          sleep 3
          recnt += 1
          puts asin + ' retry ' + recnt.to_s
          retry
        else
          raise e
        end
      end

      res.items.each do |item|
        element = item.get_element('ItemAttributes')
        data = {
          :title => item.get('ItemAttributes/Title').to_s.gsub(/ \[Blu-ray\]/, '').gsub(/ \(Ultimate Edition\)/, ''),
          :item_page_url => item.get('DetailPageURL').to_s,
          :small_image_url => item.get('SmallImage/URL').to_s,
          :medium_image_url => item.get('MediumImage/URL').to_s,
          :large_image_url => item.get('LargeImage/URL').to_s,
          :author => element.get_array('Author').join(', '),
          :product_group => element.get('ProductGroup'),
          :manufacturer => element.get('Manufacturer'),
          :publication_date => element.get('PublicationDate'),
        }
        @result_cache[asin] = data
        open(@cache_dir + asin, 'w'){|f| f.write(Marshal.dump(data))} if @cache
        break
      end
      return @result_cache[asin]
    end

    private_class_method :new
  end

  class AmazonTag < Liquid::Tag

    def initialize(name, params, token)
      super
      @params = params

      # make image alias methods for degression
      make_image_alias_methods
    end

    def render(context)
      if @params =~ /(?<type>(text|(small|large|medium)?_?image|detail|title)\s+)(?<asin>\S+)/i
        type = $~['type'].strip
        asin = $~['asin'].strip.gsub(/"|&ldquo;|&rdquo;/, '')
      else
        raise 'parametor error for amazon tag'
      end

      AmazonResultCache.instance.setup(context)
      item = AmazonResultCache.instance.item_lookup(asin)

      if item.nil?
        raise "item data empty asin %s" % [asin]
      end

      self.send(type, item)
    end

    def title(item)
      url = item[:item_page_url]
      title = item[:title]
      '<a href="%s">%s</a>' % [url, title]
    end
    # for degression
    alias text title

    def image(item, size = 'medium')
      image_url = item["#{size}_image_url".to_sym]
      url = item[:item_page_url]
      '<a href="%s"><img src="%s" /></a>' % [url, image_url]
    end

    def make_image_alias_methods
      for size in ['small', 'medium', 'large'] do
        method = "#{size}_image".to_sym
        self.class.send(:define_method, method) do |item|
          size = __method__.to_s.sub(/_image/, '')
          image(item, size)
        end
      end
    end

    def check_param(param)
      return nil unless param
      return param
    end

    def print_product_content(item, max_title_chars = nil)
      url = item[:item_page_url]
      title = item[:title]
      unless max_title_chars.nil? then
        title = title[0..max_title_chars] + '...' if title.length > max_title_chars
      end
      contents = {
        author: I18n.t('author') + ':',
        publication_date: I18n.t('publication date') + ':',
        manufacturer: I18n.t('manufacturer') + ':',
        product_group: I18n.t('product group') + ':',
      }
      res = '<a href="%s">%s</a>' % [url, title]
      res += '<p>'
      contents.each do |key, value|
        res += "#{value}\t#{item[key]}<br />" if check_param item[key]
      end
      res += '</p>'
    end

    def detail(item)
      res ='<div class="amazon_tag">'
      res += '<a target="_blank" href="%s"><img src="%s" /></a>' %
        [item[:item_page_url], item[:medium_image_url] ]
      res += '<div class="item_detail">'
      res += print_product_content item, 40
      res += '</div>' * 2
    end
  end
end

Liquid::Template.register_tag('amazon', Jekyll::AmazonTag)
