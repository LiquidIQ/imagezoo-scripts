require 'csv'
require 'pry'

csv_shopify_products = CSV.read("products_export.csv")
csv_all_products = CSV.read('all.csv')

SHOPIFY_SKU_COL = 13
SKU_COL = 0

def sku_array_from_shopify_csv(csv, col)
    csv_products = Array.new
    csv.each_with_index do |row, i|
        unless i%2 == 0
            csv_products << row[col][0...-3]
        end
    end
    return csv_products
end

def sku_array_from_csv(csv, col)
    csv_products = Array.new
    csv.each do |row|
        csv_products << row[col]
    end
end

def what_is_shopify_missing(shopify_products, all_products)
    all_products.each do |row|
        if shopify_products.include? row[0]
            puts "#{row[0]} found"
        else 
            CSV.open("missing-products.csv", "ab") do |csv|
                csv << [row[0]]
            end
        end
    end
end

shopify_products = sku_array_from_shopify_csv(csv_shopify_products, SHOPIFY_SKU_COL)
all_products = sku_array_from_csv(csv_all_products, SKU_COL)
what_is_shopify_missing(shopify_products, all_products)



