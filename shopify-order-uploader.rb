require 'csv'
require 'rubygems'
require 'shopify_api'
require 'pry'

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"

shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url


binding.pry