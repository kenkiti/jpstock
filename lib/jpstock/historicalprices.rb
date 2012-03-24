# coding: utf-8

module JpStock
  class HistoricalPricesException < StandardError
  end
  
  class HistoricalRange
    DAILY = "d" # デイリー
    WEEKLY = "w" # 週間
    MONTHLY = "m" # 月間
  end
  
  # 過去の株価データを取得
  # :code 証券コード
  # :all 過去のすべて
  # :start_date 開始日時
  # :end_date 終了日時
  # :range_type デイリー, 週間, 月間
  def historical_prices(options)
    if options.nil? or !options.is_a?(Hash)
      raise HistoricalPricesException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise HistoricalPricesException, ":codeが指定されてないです"
    end
    if !options[:code].is_a?(Array)
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].uniq!
    options[:code].each do |code|
      if (/^\d{4}$/ =~ code).nil?
        raise HistoricalPricesException, "指定された:codeの一部が不正です"
      end
    end
    if options[:all].nil? or (options[:all] != true and options[:all] != false)
      options[:all] = false
    end
    if options[:all] == false and (options[:start_date].nil? or options[:end_date].nil?)
      raise HistoricalPricesException, ":start_dateか:end_dateのどっちかが指定されてないです"
    end
    if options[:all]
      options[:start_date] = Date.new(1900, 1, 1)
      options[:end_date] = Date.today
    end
    if !options[:start_date].is_a?(Date) or !options[:end_date].is_a?(Date)
      raise HistoricalPricesException, ":start_dateか:end_dateの型がDateじゃないです"
    end
    if options[:range_type].nil?
      options[:range_type] = HistoricalRange::DAILY
    end
    if ![HistoricalRange::DAILY, HistoricalRange::WEEKLY, HistoricalRange::MONTHLY].include?(options[:range_type])
      raise HistoricalPricesException, ":range_typeがおかしいです"
    end

    codes = options[:code]
    start_date = options[:start_date]
    end_date = options[:end_date]
    range_type = options[:range_type]

    syear = start_date.year
    smon = start_date.month
    sday = start_date.day
    eyear = end_date.year
    emon = end_date.month
    eday = end_date.day
    
    results = {}
    codes.each do |code|
      results[code] = []
      500.times do |page|
        page *= 50 # 50ずつ増えてく
        site_url = "http://table.yahoo.co.jp/t?c=#{syear}&a=#{smon}&b=#{sday}&f=#{eyear}&d=#{emon}&e=#{eday}&g=#{range_type}&s=#{code}&y=#{page}&z=#{code}.t&x=.csv"
        html = open(site_url, "r:euc-jp").read.encode('utf-8', :invalid => :replace, :undef => :replace)
        doc = Nokogiri::HTML(html)
        trs = doc.xpath('//tr[@align="right" and @bgcolor="#ffffff"]')
        if trs.empty?
          break
        end
        
        data_field_num = 7
        trs.each do |tr|
          tds = tr.xpath('.//td')
          if tds.length == data_field_num
            row = tds.map{|td| td.text.strip}
            results[code].push(PriceData.new(row[0], row[1], row[2], row[3], row[4], row[5], row[6]))
          end
        end
        sleep(0.5)
      end
    end
    return results
  end
  
  module_function :historical_prices
end
