# coding: utf-8
# EDINET

module JpStock
  class EdinetException < StandardError
  end
  
  # 証券コードをEDINETコードに変換
  # :code 証券コード
  def sec2edi(options)
    if options.nil? or !options.is_a?(Hash)
      raise EdinetException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise EdinetException, ":codeが指定されてないです"
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
    
    # 証券コード - EDINETコード対応表を読み込み
    dict = {}
    CSV.open(File.join(File.dirname(__FILE__), 'edinet.csv'), 'r') do |csv|
      csv.each do |rows|
        dict[rows[0]] = rows[1]
      end
    end
    results = {}
    codes.each do |code|
      results[code] = dict[code] if dict[code]
    end
    results
  end
  
  # EDINETコードを証券コードに変換
  # :code EDINETコード
  def edi2sec(options)
    if options.nil? or !options.is_a?(Hash)
      raise EdinetException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise EdinetException, ":codeが指定されてないです"
    end
    if !options[:code].is_a?(Array)
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].uniq!
    options[:code].each do |code|
      if (/^E\d{5}$/ =~ code).nil?
        raise PriceException, "指定された:codeの一部が不正です"
      end
    end
    codes = options[:code]
    
    # 証券コード - EDINETコード対応表を読み込み
    dict = {}
    CSV.open(File.join(File.dirname(__FILE__), 'edinet.csv'), 'r') do |csv|
      csv.each do |rows|
        dict[rows[1]] = rows[0]
      end
    end
    results = {}
    codes.each do |code|
      results[code] = dict[code] if dict[code]
    end
    results
  end
  
  module_function :sec2edi, :edi2sec
end
  