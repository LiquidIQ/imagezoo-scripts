require 'csv'
require 'shopify_api'
require 'date'

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"
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

def build_artist_hash(artists)
    csv_artists = CSV.read('iz-artists.csv')

    csv_artists.each do |row|
        artists << { row[ID_COL] => row[NAME_COL] }
    end

    puts artists

    return artists
end

def send_prods_to_shopify(artists, products)
    product_images = get_product_images("all.txt")
    csv_products = CSV.read('iz-images.csv')
    puts product_images
    csv_products.each do |row|
        vendor_name = artist_id_to_name(artists, row[SUPPLIER_COL])
        # puts vendor_name
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
            ]
        })
        begin
            product.save
            CSV.open("uploaded-products.csv", "ab") do |csv|
                csv << [product.sku]
            end
            puts Time.now
        rescue ActiveResource::ClientError => e
            puts e.message
            sleep(10)
            retry
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

def get_product_images(filename)
    txt_products = File.open(filename, "r")
    products = Array.new

    txt_products.each_line do |line|
        products << [line[0], line[1]]
    end
    return products
end

artists = build_artist_hash(artists)
send_prods_to_shopify(artists, products)
