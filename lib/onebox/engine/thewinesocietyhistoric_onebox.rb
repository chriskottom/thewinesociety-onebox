I18n.enforce_available_locales = false

module Onebox
  module Engine
    class TheWineSocietyHistoricOnebox
      include TheWineSocietyEngine

      # Example product URLs:
      # http://www.thewinesociety.com/shop/historicproductdetail.aspx?...
      # http://www.thewinesociety.com/shop/HistoricProductDetail.aspx?...
      # https://www.thewinesociety.com/shop/historicproductdetail.aspx?...
      # https://www.thewinesociety.com/shop/HistoricProductDetail.aspx?...
      matches_regexp(%r{^https?://www\.thewinesociety\.com/shop/historicproductdetail\.aspx\?}i)

      private

      def price(product_info = {})
        raise NotImplementedError, 'Price not given for historic wines and vintages'
      end

      def unit(product_info = nil)
        raise NotImplementedError, 'Unit not given for historic wines and vintages'
      end

      def data
        og   = ::Onebox::Helpers.extract_opengraph(raw)

        {
          image: og[:image] || image,
          link: decoded_link,
          title: og[:title] || title,
          description: description(og[:description]),
          last_updated: last_updated(og[:updated_time])
        }
      end
    end
  end
end
