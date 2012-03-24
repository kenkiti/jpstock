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
    if options[:code].to_s.length != 4
      raise PriceException, "指定された:codeが不正です"
    end
    code = options[:code]
    
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
        return PriceData.new(Date.today(), row[4], row[5], row[6], row[0], row[3], row[0])
      end
      return nil
    end
  end
  
  module_function :price
end
