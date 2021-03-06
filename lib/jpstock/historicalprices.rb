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
    options[:return_array] = true
    if !options[:code].is_a?(Array)
      options[:return_array] = false
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
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
    if !options[:start_date].is_a?(Date)
      begin
        options[:start_date] = Date.strptime(options[:start_date], '%Y/%m/%d')
      rescue
        raise HistoricalPricesException, ":start_dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
      end
    end
    if !options[:end_date].is_a?(Date)
      begin
        options[:end_date] = Date.strptime(options[:end_date], '%Y/%m/%d')
      rescue
        raise HistoricalPricesException, ":end_dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
      end
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
    
    results = []
    codes.each do |code|
      data = []
      500.times do |page|
        page += 1
        site_url = "http://info.finance.yahoo.co.jp/history/?code=#{code}&sy=#{syear}&sm=#{smon}&sd=#{sday}&ey=#{eyear}&em=#{emon}&ed=#{eday}&tm=#{range_type}&p=#{page}"
        html = open(site_url).read
        doc = Nokogiri::HTML(html)
        table = doc.xpath('//table[@class="boardFin yjSt marB6"]')
        if table.empty?
          break
        end
        trs = table.xpath('.//tr')
        trs.shift
        if trs.empty?
          break
        end
        
        data_field_num = 7
        trs.each do |tr|
          tds = tr.xpath('.//td')
          if tds.length == data_field_num
            row = tds.map{|td| td.text.strip}
            begin
              data.push(PriceData.new(code, row[0], row[1], row[2], row[3], row[4], row[5], row[6]))
            rescue
            end
          end
        end
        sleep(0.5)
      end
      results.push(data)
    end
    results = results[0] unless options[:return_array]
    return results
  end
  
  module_function :historical_prices
end
