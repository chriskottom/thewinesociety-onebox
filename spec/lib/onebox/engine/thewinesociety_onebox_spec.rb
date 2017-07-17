# coding: utf-8
require_relative '../../../spec_helper.rb'

describe Onebox::Engine::TheWineSocietyOnebox do
  let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=CE8721' }
  let(:html) { described_class.new(link).to_html }
  let(:parsed_html) { Nokogiri::HTML(html) }

  before do
    fake(link, response('thewinesociety'))
  end

  it 'uses the image from the meta tag' do
    image_node = parsed_html.at_css('img.thumbnail')
    expect(image_node[:src]).to match(%r{resources/product_images/CE8721\.jpg})
  end

  it 'uses the link as supplied by the user' do
    header_node = parsed_html.at_css('header.source a')
    expect(header_node[:href]).to eq(link)
    expect(header_node.text).to eq('thewinesociety.com')

    title_node = parsed_html.at_css('h3 a')
    expect(title_node[:href]).to eq(link)
    expect(title_node.text).to eq('Concha y Toro Corte Ignacio Casablanca Riesling 2015')
  end

  it 'uses the unaltered description from the meta tag' do
    description_node = parsed_html.at_css('p.description')
    description = description_node.text

    expected = 'A lovely floral Chilean riesling with some white-pepper '\
               'aromas. The palate is just off-dry, its refreshing acidity '\
               'balanced by a light honeyed character.'
    expect(description).to eq(expected)
    expect(description).not_to match(/\.\.\.$/)
  end

  it 'uses the price from the meta tag' do
    price_node = parsed_html.at_css('p.priceline strong .price')
    expect(price_node.text).to eq('£8.50')
  end

  it 'uses the unit string from the page' do
    unit_node = parsed_html.at_css('p.priceline .unit')
    expect(unit_node.text).to eq('per bottle')
  end

  it 'uses the last updated date from the meta tag' do
    updated_node = parsed_html.at_css('p.last-updated')
    expect(updated_node.text).to eq('Details correct as at: 05/07/2017 07:17:25')
  end

  context 'when the description contains markup and HTML entity codes' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=WB80399' }

    before do
      fake(link, response('thewinesociety-item-unit'))
    end

    it 'decodes the entities and strips out the tags' do
      description_node = parsed_html.at_css('p.description')
      description = description_node.text

      expected = 'Made of stained wood, the wine bin kit comes complete '\
                 'with instructions and connectors. 8 x 10 openings for a '\
                 'maximum of 90 bottles. Measures 100.5cm x 91.5cm (39½" '\
                 'x 36"). Price includes UK delivery.'
      expect(description).to eq(expected)
    end
  end

  context 'when the units are non-standard' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=WB80399' }

    before do
      fake(link, response('thewinesociety-item-unit'))
    end

    it 'uses "item" as the unit' do
      unit_node = parsed_html.at_css('p.priceline .unit')
      expect(unit_node.text).to eq('per item')
    end
  end

  context 'when the units are weird' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=SB997' }

    before do
      fake(link, response('thewinesociety-weird-unit'))
    end

    it 'uses "unit" as the unit' do
      unit_node = parsed_html.at_css('p.priceline .unit')
      expect(unit_node.text).to eq('per unit')
    end
  end

  context 'when the link is URL encoded' do
    let(:link) { 'https://www.thewinesociety.com/shop/productdetail.aspx?section=pd&pl=&pd=CE8721&prl=STD' }

    it 'decodes it before display' do
      header_node = parsed_html.at_css('header.source a')
      expect(header_node[:href]).to eq(link)

      title_node = parsed_html.at_css('h3 a')
      expect(title_node[:href]).to eq(link)
    end
  end

  context 'when the product description is long' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=AU19391' }

    before do
      fake(link, response('thewinesociety-long-description'))
    end

    it 'truncates the description' do
      description_node = parsed_html.at_css('p.description')
      description = description_node.text
      expect(description.length).to be <= 300
      expect(description).to match /\.\.\.$/
    end
  end

  context 'when no OpenGraph information is present' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=IT21221' }

    before do
      time = DateTime.parse('2017-07-05 12:13:14')
      allow(DateTime).to receive(:now).and_return(time)

      fake(link, response('thewinesociety-no-og'))
    end

    it 'responds based on the relative image URL from the page' do
      image_node = parsed_html.at_css('img.thumbnail')
      image_url = 'http://www.thewinesociety.com/resources/product_images/IT21221.jpg'
      expect(image_node[:src]).to eq(image_url)
    end

    it 'uses the title from the page header' do
      title_node = parsed_html.at_css('h3 a')
      expect(title_node[:href]).to eq(link)
      expect(title_node.text).to eq('Tarantino Primitivo Segnavento, Pervini 2015')
    end

    it 'uses the unaltered description from the page' do
      description_node = parsed_html.at_css('p.description')
      description = description_node.text

      expected = 'A juicy sappy blackberry-flavoured red from the heart '\
                 'of primitivo country. Made to be enjoyed in its youth.'
      expect(description).to eq(expected)
      expect(description).not_to match(/\.\.\.$/)
    end

    it 'uses the price from the page' do
      price_node = parsed_html.at_css('p.priceline strong .price')
      expect(price_node.text).to eq('£6.75')
    end

    it 'uses the current date and time as last updated' do
      updated_node = parsed_html.at_css('p.last-updated')
      expect(updated_node.text).to eq('Details correct as at: 05/07/2017 12:13:14')
    end
  end
end
