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
    if !options[:code].is_a?(Array)
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].uniq!
    options[:code].each do |code|
      if (/^\d{4}$/ =~ code).nil?
        raise PriceException, "指定された:codeの一部が不正です"
      end
    end
    codes = options[:code]
    
    results = {} # 証券コードをキーにしたハッシュを返す
    codes.each do |code|
      site_url = "http://quote.yahoo.co.jp/q?s=#{code}&d=v2&esearch=1"
      html = open(site_url, "r:euc-jp").read.encode('utf-8', :invalid => :replace, :undef => :replace)
      doc = Nokogiri::HTML(html)
      trs = doc.xpath('//tr[@align="right"]')
      
      data_field_num = 11 # 取得した要素数がこの値だったらOKとする
      trs.each do |tr|
        tds = tr.xpath('.//td')
        if tds.length == data_field_num
          tds = tds.slice(3, 10) # 不必要な要素を削除
          row = tds.map{|td| td.text.strip}
          results[code] = PriceData.new(Date.today(), row[4], row[5], row[6], row[0], row[3], row[0])
        end
      end
      sleep(0.5)
    end
    return results
  end
  
  module_function :price
end
