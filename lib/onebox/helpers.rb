module Onebox
  module Helpers

    def self.extract_opengraph(doc)
      return {} unless doc

      og = {}

      doc.css('meta').each do |m|
        if (m["property"] && m["property"][/^og:(.+)$/i]) ||
           (m["name"] && m["name"][/^og:(.+)$/i])
          value = (m["content"] || m["value"]).to_s
          og[$1.tr('-:','_').to_sym] ||= value unless Onebox::Helpers::blank?(value)
        end
      end

      og
    end

    def self.extract_product_info(doc)
      return {} unless doc

      product_info = {}

      doc.css('meta').each do |m|
        if (m["property"] && m["property"][/^product:(.+)$/i]) ||
           (m["name"] && m["name"][/^product:(.+)$/i])
          value = (m["content"] || m["value"]).to_s
          product_info[$1.tr('-:','_').to_sym] ||=
            value unless Onebox::Helpers::blank?(value)
        end
      end

      product_info
    end
  end
end
