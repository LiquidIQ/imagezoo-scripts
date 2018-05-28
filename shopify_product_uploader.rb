require 'csv'
require 'rubygems'
require 'shopify_api'
require 'pry'


WATERMARK_URL = "http://watermarklibs.s3-website-us-east-1.amazonaws.com/"  
API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"
CYCLE = 0.5
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

artists = Array.new
products = Array.new

ID_COL = 0
NAME_COL = 1
SUPPLIER_COL = 1
DATE_COL = 2
TITLE_COL = 3
COLLECTION_COL = 26
CSV.open("uploaded-products.csv", "ab")

def build_artist_hash(artists)
    csv_artists = CSV.read('iz-artists.csv')
    csv_artists.each do |row|
        artists << { row[ID_COL] => row[NAME_COL] }
    end
    return artists
end


def prod_already_uploaded(product_id)
    uploaded_products = CSV.read("uploaded-products.csv")
    id_list = Array.new
    uploaded_products.each do |row|
        id_list << row[0]
    end
    return id_list.index {|e| e.include? product_id} == nil ? false : true
end

def prod_not_in_aws(product_id)
    aws_products = CSV.read("all2.csv")
    id_list = Array.new
    aws_products.each do |row|
        id_list << row[0]
    end
    return id_list.index {|e| e.include? product_id} == nil ? true : false
end

def send_prods_to_shopify(artists, products)
    csv_products = CSV.read('iz-images.csv')
    product_count = csv_products.size

    start_time = Time.now
    products_remaining = product_count
    processing_average = Array.new

    csv_products.each do |row|
        # avoiding duplication of server work 
        if prod_already_uploaded(row[ID_COL]) || prod_not_in_aws(row[ID_COL])
            products_remaining -= 1
            puts products_remaining
            csv_skipped = CSV.open("skipped-uploads.csv", "ab") do |csv|
                csv << [row[ID_COL]]
                # binding.pry
            end
            next
        end

        # convert vendor initials to full name
        vendor_name = artist_id_to_name(artists, row[SUPPLIER_COL])

        # pausing to keep our shopify api_call bucket full
        stop_time = Time.now
        processing_duration = stop_time - start_time
        processing_average << processing_duration
        puts "The processing lasted #{processing_duration.to_i} seconds."
        puts "#{products_remaining} Remaining"
        wait_time = (CYCLE - processing_duration).ceil
        puts "We have to wait #{wait_time} seconds then we will resume."
        sleep wait_time if wait_time > 0
        start_time = Time.now

        # we know that this exists if we're here
        product_watermark = get_product_image(row[ID_COL])

        product = ShopifyAPI::Product.new({
            title: row[TITLE_COL], 
            vendor: vendor_name,
            product_type: "Image",
            sku: row[ID_COL],
            variants: [
                {
                    option1: "Hi-Res .jpg",
                    price: "2.00",
                    sku: "#{row[ID_COL]}-HR"
                },
                {
                    option1: "Web-Res .jpg",
                    price: "1.00",
                    sku: "#{row[ID_COL]}-Web"
                }
            ],
            images: [
                src: product_watermark
            ]
        })

        product.save
        products_remaining -= 1

        CSV.open("uploaded-products.csv", "ab") do |csv|
            csv << [product.sku]
        end
    end
end

def artist_id_to_name(artists, id)
    if a = artists.find {|h| h.key? id } then
        return a[id]
    else
        puts "#{id} not found"
    end
end

def get_product_image(image_id)
    csv_products = CSV.open("all.csv")
    products = Hash.new

    csv_products.each do |row|
        products.store(row[0], row[1])
    end
    return "#{WATERMARK_URL}#{products.dig(image_id)}"
end

artists = build_artist_hash(artists)
send_prods_to_shopify(artists, products)
