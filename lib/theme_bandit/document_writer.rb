require 'pry'
module ThemeBandit
  class DocumentWriter
    include ThemeBandit::CSSParser
    include ThemeBandit::JSParser
    include ThemeBandit::HTMLParser
    # TODO: image parser
    # TODO: font parser

    attr_accessor :document
    attr_reader :url

    CSS_FOLDER   =  './theme/public/css/'
    JS_FOLDER    =  './theme/public/js/'
    HTML_FOLDER  =  './theme/public/'

    def initialize(doc, url = ThemeBandit.configuration.url)
      @document, @url = Nokogiri::HTML(doc), URI.parse(url)
    end

    def write
      write_html_revision
    end

    def html
      document.to_html
    end

    def write_html_revision
      download_css(get_css_files)
      download_js(get_js_files)
      revise_head_tags
      write_html_file
    end

    def make_dir(folder)
      FileUtils.mkdir_p folder
    end

    def download_css(files)
      make_dir(CSS_FOLDER)
      files.each_with_index do |file, order|
        download_single_css_file(file, order)
      end
    end

    def download_single_css_file(file_name, order)
      doc = Downloader.fetch(file_name, {}).body
      download_css_imports(doc, file_name)
      new_file_name = file_name.split('/').last
      File.open("#{CSS_FOLDER}#{order}_#{new_file_name}", 'w') { |file| file.write(doc) }
    end

    # Use recurison to get to deepest level
    def download_css_imports(doc, file_name)
      if imports = get_import_urls(doc, file_name)
        download_css(imports)
      end
    end

    def download_js(files)
      make_dir(JS_FOLDER)
      files.each_with_index do |file_name, order|
        doc = Downloader.fetch(file_name, {})
        new_file = file_name.split('/').last
        File.open("#{JS_FOLDER}#{order}_#{new_file}", 'w') { |file| file.write(doc.body) }
      end
    end

    def write_html_file
      File.open("#{HTML_FOLDER}index.html", 'w') { |file| file.write(html) }
    end
  end
end
