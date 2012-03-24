# coding: utf-8
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'open-uri'
require 'nokogiri'
require 'date'
require 'jpstock/base'
require 'jpstock/price'
require 'jpstock/historicalprices'
require 'jpstock/brand'
require 'jpstock/finance'

#p JpStock.price(:code=>"3632")
#p JpStock.brand(:category => ['0050', 'abc', '1050'])

