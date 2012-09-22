# coding: utf-8
# EDINET

module JpStock
  class EdinetException < StandardError
  end
  
  # EDINETコード
  class Edicode
    attr_accessor :code, :edicode
    def initialize(code, edicode)
      @code = code # 証券コード
      @edicode = edicode # EDINETコード
    end
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
    
    # 証券コード - EDINETコード対応表を読み込み
    dict = {}
    CSV.open(File.join(File.dirname(__FILE__), 'edinet.csv'), 'r') do |csv|
      csv.each do |rows|
        dict[rows[0]] = rows[1]
      end
    end
    
    results = []
    codes.each do |code|
      if dict[code]
        results.push(Edicode.new(code, dict[code]))
      else
        results.push(nil)
      end
    end
    results = results[0] unless options[:return_array]
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
    options[:return_array] = true
    if !options[:code].is_a?(Array)
      options[:return_array] = false
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
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
    
    results = []
    codes.each do |code|
      if dict[code]
        results.push(Edicode.new(dict[code], code))
      else
        results.push(nil)
      end
    end
    results = results[0] unless options[:return_array]
    results
  end
  
  module_function :sec2edi, :edi2sec
end
  