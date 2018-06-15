require 'csv'
require 'rubygems'
require 'shopify_api'
require 'pry'

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"
WAIT_TIME = 1
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

csv_products = CSV.read("products_export_newest.csv")
HANDLE_COL = 0

product_count = csv_products.size
products_remaining = product_count/2
start_time = Time.now
START_PT = 42245
csv_products.drop(START_PT).each_with_index do |row, i|
    if i%2 == 1
        # stop_time = Time.now
        # processing_duration = stop_time - start_time
        # puts "The processing lasted #{processing_duration.to_i} seconds."
        # wait_time = (CYCLE - processing_duration).ceil
        # puts "We have to wait #{wait_time} seconds then we will resume."
        # sleep wait_time if wait_time > 0
        # puts "#{products_remaining} Remaining"
        # products_remaining -= 1
        
        # start_time = Time.now

        begin
            p = ShopifyAPI::Product.find(:first, :params=> {:handle => row[HANDLE_COL]});
            p.handle = p.variants[0].sku[0...-3]
            p.variants[0].requires_shipping = false
            p.variants[1].requires_shipping = false
            p.save
            sleep WAIT_TIME
            p "saved #{p.handle} ~#{(csv_products.size - (START_PT + i))/2} remaining"
            csv_handled = CSV.open("handled_products.csv", "a+") do |csv|
                csv << [p.handle]
            end
            
            rescue NoMethodError => e
                puts "#{row[HANDLE_COL]}: skipping #{i}/#{csv_products.size}"
                csv_skipped = CSV.open("skipped_handling.csv", "a+") do |csv|
                    csv << [row[HANDLE_COL]]
                end
                sleep 0.5
                next
            rescue ActiveResource::ClientError, Errno::ENETDOWN, ActiveResource::TimeoutError, ActiveResource::ServerError => e
                puts "#{e}: retrying #{row[HANDLE_COL]}"
                sleep 5
                retry   
        end
    end
end
