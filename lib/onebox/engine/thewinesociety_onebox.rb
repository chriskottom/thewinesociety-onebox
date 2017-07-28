require 'money'

I18n.enforce_available_locales = false

module Onebox
  module Engine
    class TheWineSocietyOnebox
      include TheWineSocietyEngine

      # Example product URLs:
      # http://www.thewinesociety.com/shop/ProductDetail.aspx?...
      # http://www.thewinesociety.com/shop/productdetail.aspx?...
      # https://www.thewinesociety.com/shop/ProductDetail.aspx?...
      # https://www.thewinesociety.com/shop/productdetail.aspx?...
      matches_regexp(%r{^https?://www\.thewinesociety\.com/shop/productdetail\.aspx\?}i)

      private

      def data
        og   = ::Onebox::Helpers.extract_opengraph(raw)
        prod = ::Onebox::Helpers.extract_product_info(raw)

        {
          image: og[:image] || image,
          link: decoded_link,
          title: og[:title] || title,
          description: description(og[:description]),
          price: price(prod),
          unit: unit(prod),
          last_updated: last_updated(og[:updated_time])
        }
      end
    end
  end
end
