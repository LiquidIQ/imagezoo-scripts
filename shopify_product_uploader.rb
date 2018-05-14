require 'csv'
require 'shopify_api'

csv_products = CSV.read('iz-images.csv')
# csv_artists = CSV.read('iz-artists.csv')

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
TITLE_COL = 5
COLLECTION_COL = 26

def build_artist_hash(artists)
    csv_artists.each do |row|
        artists << { row[ID_COL] => row[NAME_COL] }
    end
    return artists
end

def send_prods_to_shopify(artists, products)
    
    # TAGS_COL = 36...264
    # .to_time.iso8601
    csv_products.each do |row|
        @vendorName = artist_id_to_name(artists, row[SUPPLIER_COL])
        product = ShopifyAPI::Product.new({
            title: row[TITLE_COL], 
            vendor: @vendor_name,
            product_type: "Image",
            created_at: row[DATE_COL].to_time.iso8601
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
    end
end

artist = build_artist_hash(artist)
send_prods_to_shopify(artist, products)
