# coding: utf-8

module JpStock
  
  # 株価データ
  class PriceData
    attr_accessor :code, :date, :open, :high, :low, :close, :volume
    
    def initialize(code, date, open, high, low, close, volume, adj_close)
      @code = code
      @date = to_date(date)
      @open = to_float(open)
      @high = to_float(high)
      @low = to_float(low)
      @close = to_float(close)
      @volume = to_float(volume)
      adjust(to_float(adj_close))
    end
    
    private 
    def adjust(adj_close)
      rate = @close / adj_close
      if rate > 1
          @open /= rate
          @high /= rate
          @low /= rate
          @close /= rate
          @volume *= rate
      end
    end
    
    def to_date(val)
      if val.instance_of?(Date)
        return val
      end
      begin
        return Date.strptime(val, '%Y年%m月%d日')
      rescue
        return Date.strptime(val, '%Y年%m月')
      end
    end
    
    def to_float(val)
      if val.instance_of?(String)
        val.gsub!(',', '')
      end
      val.to_f
    end
    
  end
  
  class Util
    # 日証金?
    def self.is_jsf?(market)
      ['東証1部', '東証2部', '東証外国'].include?(market)
    end
    
    # 大証金?
    def self.is_osf?(market)
      ['JQS', 'JQG', '大証1部', '大証2部'].include?(market)
    end
  end
  
end
