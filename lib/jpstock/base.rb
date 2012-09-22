# coding: utf-8

module JpStock
  
  # 株価データ
  class PriceData
    attr_accessor :code, :date, :open, :high, :low, :close, :volume
    
    def initialize(code, date, open, high, low, close, volume, adj_close)
      @code = to_int(code)
      @date = to_date(date)
      @open = to_int(open)
      @high = to_int(high)
      @low = to_int(low)
      @close = to_int(close)
      @volume = to_int(volume)
      adjust(to_int(adj_close))
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
    
    def to_int(val)
      if val.instance_of?(String)
        val.gsub!(',', '')
      end
      return val.to_i
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
