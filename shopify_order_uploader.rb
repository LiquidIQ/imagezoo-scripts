require 'csv'
require 'rubygems'
require 'shopify_api'
require 'pry'

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"

shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

csv_products = CSV.read("products_export.csv")
csv_clients = CSV.read("customers_export.csv")
csv_old_sales = CSV.read("iz-sales.csv")
csv_old_clients = CSV.read("iz-clients.csv")

IMG_ID_COL = 0
CLIENT_COL = 4

# Create a hash of all clients on Shopify
# Add old id from csv_old_clients to hash
# get id from csv_old_sales
# check client hash for id
# for id = client.id 
    # add matching product id from csv_products to client 

