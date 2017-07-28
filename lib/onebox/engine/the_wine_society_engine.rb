module Onebox
  module Engine
    module TheWineSocietyEngine
      MAX_DESCRIPTION_CHARS = 300
      FALLBACK_UNIT = 'unit'
      WEIRD_UNITS = %w(each)

      def self.included(base)
        base.include Engine
        base.include LayoutSupport
        base.include HTML
      end

      private

      def image
        product_image = raw.at_css('.pnl-product-image img')
        if product_image
          image_url = product_image[:src]
          if image_url =~ /^http/
            image_url
          elsif image_url =~ %r{^\.\./resources/}
            image_url.sub(/^\.\./, 'http://www.thewinesociety.com')
          else
            nil
          end
        end
      end

      def decoded_link
        HTMLEntities.new.decode(link)
      end

      def title
        title_node = raw.at_css('h1.productName')
        if title_node
          title_node.text.strip
        end
      end

      def description(text = nil)
        if !text
          all_content_node = raw.at_css('.pnl-product-detail-description .allcontent')
          if all_content_node
            text = all_content_node.text
          else
            description_node = raw.at_css('.pnl-product-detail-description .truncatable')
            if description_node
              text = description_node.text
            end
          end
        end

        text = HTMLEntities.new.decode(text.strip)
        text = Sanitize.fragment(text)
        Onebox::Helpers.truncate(text, MAX_DESCRIPTION_CHARS)
      end

      def price(product_info = {})
        if product_info[:price_amount] && product_info[:price_currency]
          cents = product_info[:price_amount].to_f * 100
          money = Money.new(cents, product_info[:price_currency])
          money.format
        else
          price_node = raw.css('.pnl-buy-pricing').first
          if price_node
            price_node.text.strip.sub(/\s.*$/, '')
          else
            nil
          end
        end
      end

      def unit(product_info = nil)
        if product_info[:category]
          "per #{ product_info[:category] }"
        else
          price_node = raw.css('.pnl-buy-pricing').first
          if price_node
            unit_text = price_node.text.sub(/^\S+\s+/, '').strip.downcase
            unit_text = FALLBACK_UNIT if WEIRD_UNITS.include?(unit_text)

            return "per #{ unit_text }" if !unit_text.empty?
          end
        end

        "per #{ FALLBACK_UNIT }"
      end

      def last_updated(timestamp = nil)
        if timestamp
          DateTime.parse(timestamp).strftime('%d/%m/%Y %H:%M:%S')
        else
          DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
        end
      end
    end
  end
end
