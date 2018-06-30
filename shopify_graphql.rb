  http = GraphQL::Client::HTTP.new("https://myshopify.com/whatever/graphql") do
    def headers(context)
      # Optionally set any HTTP headers
      { "Authorization": "whatever shopify's auth looks like" }
    end
  end  

  # Fetch latest schema on init, this will make a network request
  schema = GraphQL::Client.load_schema(HTTP)

  # However, it's smart to dump this to a JSON file and load from disk
  #
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
  #
  # Schema = GraphQL::Client.load_schema("path/to/schema.json")

  client = GraphQL::Client.new(schema: schema, execute: HTTP)

  add_products_mutation_string = ""

  foreach product in products
      add_products_mutation_string.append <<-'END'
      mutation {
        inventoryAdjustQuantity(
          input:{
            inventoryLevelId: "gid://shopify/InventoryLevel/13570506808?inventory_item_id=10820777115690"
            availableDelta: 1
          }
        )
        {
          inventoryLevel {
            available
          }
        }
      }
      END

  add_products_mutation_string = client.parse(add_products_mutation_string)
  client.execute(mutation)
  add_products = SWAPI::Client.parse
    query {
    hero {
      name
    }
  }
GRAPHQL

