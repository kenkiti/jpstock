# coding: utf-8

module JpStock
  class FinanceException < StandardError
  end
  
  # 財務情報を取得
  def finance(options)
    if options.nil? or !options.is_a?(Hash)
      raise FinanceException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise FinanceException, ":codeが指定されてないです"
    end
    if options[:code].to_s.length != 4
      raise FinanceException, "指定された:codeが不正です"
    end
    code = options[:code]
    
    site_url = "http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}"
    html = open(site_url).read
    doc = Nokogiri::HTML(html)
    trs = doc.xpath('//div[@class="chartFinance"]')
    
    
  end
  
  module_function :finance
end
