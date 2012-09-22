# coding: utf-8

module JpStock
  class PriceException < StandardError
  end
  
  # 現在の株価を取得
  # :code 証券コード
  def price(options)
    if options.nil? or !options.is_a?(Hash)
      raise PriceException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise PriceException, ":codeが指定されてないです"
    end
    options[:return_array] = true
    if !options[:code].is_a?(Array)
      options[:return_array] = false
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].each do |code|
      if (/^\d{4}$/ =~ code).nil?
        raise PriceException, "指定された:codeの一部が不正です"
      end
    end
    codes = options[:code]
    
    results = []
    codes.each do |code|
      site_url = "http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}"
      html = open(site_url).read
      doc = Nokogiri::HTML(html)
      
      # 株価抽出
      close = doc.xpath('//table[@class="stocksTable"]/tr/td')[1].text.strip
      elms = doc.xpath('//div[@class="innerDate"]/div/dl/dd[@class="ymuiEditLink mar0"]/strong')
      prev_close = elms[0].text.strip
      open = elms[1].text.strip
      high = elms[2].text.strip
      low = elms[3].text.strip
      volume = elms[4].text.strip
      results.push(PriceData.new(code, Date.today(), open, high, low, close, volume, close))
      
      sleep(0.5)
    end
    results = results[0] unless options[:return_array]
    return results
  end
  
  module_function :price
end
