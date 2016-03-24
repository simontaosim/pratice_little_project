module Pratice
  class App < Padrino::Application
    register SassInitializer
    use ConnectionPoolManagement
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions


    get 'pachong/:page/' do
      @page = params[:page]? params[:page]:1
      require 'open-uri'
      require 'mechanize'
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      if params[:url]
        @url = params[:url]
      else
        @url = 'http://www.dianping.com/search/category/8/65/p'
      end
      if params[:cate_name]
        @cate_name = params[:cate_name]
      else
        @cate_name = "成都所有地区"
      end
      begin
        page = agent.get(@url+@page.to_s)
      rescue Mechanize::ResponseReadError => e
        page = e.force_parse
      end

      @shops = []
      table = page.search("a[data-hippo-type=shop]")

      table.each do |t|
        page_detail = page.links.find { |l| l.text.include?(t.inner_text) }
        page_detail = page_detail.click
        table_name = page_detail.search('.shop-name')
        table_address = page_detail.search('.expand-info.address')
        table_phone = page_detail.search('.expand-info.tel')
        table_cate = page_detail.search('.breadcrumb a:nth-child(4)')
        shop_name = table_name[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
        shop_name = shop_name[0..shop_name.length-8]
        if table_address[0]
          shop_address = table_address[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
        else
          shop_address = "无"
        end
        if table_phone[0]
          shop_tel = table_phone[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
        else
          shop_tel = "无"
        end

        shop_cate = table_cate.inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
        @shops.push(name: shop_name, address: shop_address, tel: shop_tel, cate: shop_cate)

      end
       render 'pachong/index'
      #
      # html_doc.xpath('//h4')
      # table.inner_text[0].to_s
    end


    get 'pachong' do
      @shops = []
      for i in 1..50
        puts '邛崃区第'+i.to_s+"页============================================"
        require 'open-uri'
        require 'mechanize'
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        if params[:url]
          @url = params[:url]
        else
          @url = 'http://www.dianping.com/search/category/8/65/r27622p'
        end
        if params[:cate_name]
          @cate_name = params[:cate_name]
        else
          @cate_name = "成都所有地区"
        end
        begin
          page = agent.get(@url+i.to_s)
        rescue Mechanize::ResponseReadError => e
          page = e.force_parse
        end


        table = page.search("a[data-hippo-type=shop]")

        table.each do |t|
          page_detail = page.links.find { |l| l.text.include?(t.inner_text) }
          page_detail = page_detail.click
          table_name = page_detail.search('.shop-name')
          table_address = page_detail.search('.expand-info.address')
          table_phone = page_detail.search('.expand-info.tel')
          table_cate = page_detail.search('.breadcrumb a:nth-child(4)')
          shop_name = table_name[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
          shop_name = shop_name[0..shop_name.length-8]
          if table_address[0]
            shop_address = table_address[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
          else
            shop_address = "无"
          end
          if table_phone[0]
            shop_tel = table_phone[0].inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
          else
            shop_tel = "无"
          end

          shop_cate = table_cate.inner_text.gsub(/<\/?.*?>/,"").gsub(' ','')
          shop = QiongLaiCarShop.new
          shop.name = shop_name.gsub(/[.\n]/,"")
          shop.address = shop_address.gsub(/[.\n]/,"")[3..-1]
          shop.tel = shop_tel.gsub(/[.\n]/,"")[3..-1]
          shop.cate = shop_cate.gsub(/[.\n]/,"")
          shop.save
          @shops.push(shop)

        end

      end
      render 'pachong/show'
    end

    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache.new(:LRUHash) # Keeps cached values in memory
    # set :cache, Padrino::Cache.new(:Memcached) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Memcached, :server => '127.0.0.1:11211', :exception_retry_limit => 1)
    # set :cache, Padrino::Cache.new(:Memcached, :backend => memcached_or_dalli_instance)
    # set :cache, Padrino::Cache.new(:Redis) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Redis, :host => '127.0.0.1', :port => 6379, :db => 0)
    # set :cache, Padrino::Cache.new(:Redis, :backend => redis_instance)
    # set :cache, Padrino::Cache.new(:Mongo) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Mongo, :backend => mongo_client_instance)
    # set :cache, Padrino::Cache.new(:File, :dir => Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 500 do
    #     render 'errors/500'
    #   end
    #
  end
end
