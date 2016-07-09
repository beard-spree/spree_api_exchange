# encoding: utf-8

require 'open-uri'
require 'nokogiri'
# add custom rake tasks here
namespace :spree_api_exchange do
  eur_hash = { num_code: '978', char_code: 'EUR', name: 'Euro' }

  namespace :currency do
    desc "Load start currencies"

    task :load => :environment do
      keys = [:usd, :rub, :eur]
      keys.each do |key|
        x = ::Money::Currency.table[key]
        unless Spree::Currency.exists?(name: key)
          Spree::Currency.create(char_code: x[:iso_code],name: key,num_code: x[:iso_numeric],basic:(key==:usd) ? true :false)
        end
      end
    end
  end

  namespace :rates do
    desc 'Rates from European Central Bank'
    task :ecb, [:load_currencies] => :environment do |t, args|
      Spree::CurrencyConverter.delete_all
      if args.load_currencies
        Rake::Task['spree_api_exchange:currency:iso4217'].invoke
      end
      
      basic = Spree::Currency.find_by_basic(1)
      unless basic.present?
      
        euro  = Spree::Currency.get('978', eur_hash)
        euro.basic!
      end
      basic_value = 1
      currencies = []
      
      url = 'http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'
      data = Nokogiri::XML.parse(open(url))
      date = Date.strptime(data.xpath('gesmes:Envelope/xmlns:Cube/xmlns:Cube').attr('time').to_s, "%Y-%m-%d")
      data.xpath('gesmes:Envelope/xmlns:Cube/xmlns:Cube//xmlns:Cube').each do |exchange_rate|
        char_code      = exchange_rate.attribute('currency').value.to_s.strip
        nominal, value = exchange_rate.attribute('rate').value.to_f, 1
        
        
        #if basic.char_code == char_code

        #  basic_value = nominal
        #end
        
        currencies << {char_code: char_code, value: value,nominal: nominal}
         
      end
      currencies << eur_hash.merge({value: 1, nominal: 1} ) # basic may not be EUR

      currencies.each do |c|
        #if c[:char_code] ==  basic.char_code    # need not insert basic
        #  next
        #end
        
        currency = Spree::Currency.find_by_char_code(c[:char_code])
        currency && Spree::CurrencyConverter.add(currency, date, c[:value], c[:nominal]/basic_value)
      end
        
    end

  end

end
