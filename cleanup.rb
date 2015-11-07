require 'rubygems'    # Need this to use the shopify_api gem.
require 'shopify_api' # Tellement utile to speak to your shop.

APIKEY   = 'a0d5ba398f7eb2de0c9dc7672eb94b53'
PASSWORD = '5ca1a4d8c85a641d7eba99f7d397b19f'
SHOPNAME = 'devlopment-store'

CYCLE = 0.5     # You can average 2 calls per second, so each call ought to take a half second minimum.

# Telling your shop who's boss.
url = "https://devlopment-store.myshopify.com/admin"
ShopifyAPI::Base.site = url

# How many.
product_count = ShopifyAPI::Product.count
nb_pages      = (product_count / 250.0).ceil

# Do we actually have any work to do?
puts "Yo man. You don't have any product in your shop. duh!" if product_count.zero?

# Initializing.
start_time = Time.now

# While we still have products.
1.upto(nb_pages) do |page|
  unless page == 1
    stop_time = Time.now
    puts "Current batch processing started at #{start_time.strftime('%I:%M%p')}"
    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
    processing_duration = stop_time - start_time
    puts "The processing lasted #{processing_duration.to_i} seconds."
    wait_time = (CYCLE - processing_duration).ceil
    puts "We have to wait #{wait_time.to_i} seconds then we will resume."
    sleep wait_time
    start_time = Time.now
  end
  puts "Doing page #{page}/#{nb_pages}..."
  products = ShopifyAPI::Product.find( :all, :params => { :limit => 250, :page => page } )
  products.each do |product|
    puts product.title
    any_in_stock = product.variants.any? do |variant|
      variant.inventory_management == '' || variant.inventory_policy == 'continue' || variant.inventory_quantity > 0
    end
    if not any_in_stock
      puts "--- Deleting #{product.title}..."
      product.destroy
    end
  end
end

puts "Over and out."