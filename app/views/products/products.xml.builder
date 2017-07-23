xml << '<?xml version="1.0" encoding="utf-8"?>'
xml << "\n"
xml << '<!DOCTYPE yml_catalog SYSTEM "shops.dtd">'
xml << "\n"

xml.yml_catalog date: Time.now.strftime('%F %H:%M') do
  xml.shop do
    xml.name '1bid1'
    xml.company 'Magazin'
    xml.url 'https://1bid1.com/'
    xml.categories do
      TopCategory.all.each do |category|
        xml.category category.name, id: category.id
      end
    end
    xml.offers do
      ProductsSearch.new.all.each do |product|
        decorated = product.decorate

        xml.offer id: product.id, type: 'vendor.model', available: 'true' do
          xml.url decorated.product_url
          xml.price product.price
          xml.currencyId 'USD'
          xml.categoryId(product.category.id) if product.category
          xml.picture decorated.thumbnail_img
          xml.vendor decorated.vendor
          xml.model decorated.title
          xml.description decorated.description
        end
      end
    end
  end
end
