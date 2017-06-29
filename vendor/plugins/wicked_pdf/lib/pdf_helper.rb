module PdfHelper
  require 'wicked_pdf'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :wicked_pdf
    end
  end

  def render_with_wicked_pdf(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      logger.info '*'*15 + 'WICKED' + '*'*15
      options[:basic_auth] = request.env["HTTP_AUTHORIZATION"].split(" ").last if request.env["HTTP_AUTHORIZATION"]
      make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
    else
      render_without_wicked_pdf(options, *args, &block)
    end
  end

  private
    def make_pdf(options = {})
      html_string = render_to_string( 
                                      :template => options[:template], 
                                      :layout => options[:layout],
                                      :orientation => options[:orientation]
                                    )
      # w = WickedPdf.new(options[:wkhtmltopdf])
      # w.pdf_from_string(html_string, options)
      html_string
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:wkhtmltopdf] ||= nil
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"
      options[:orientation] ||= "portrait"

      options = prerender_header_and_footer(options)
      if options[:show_as_html]
        render :template => options[:template], :layout => options[:layout], :content_type => "text/html"
      else
        pdf_content = make_pdf(options)
        f = File.open(""+pdf_name+".html","w")
        f.write(pdf_content)
        f.close
        #cmd = "type dat/#{pdf_name}.html | \"c:\\Program Files (x86)\\wkhtmltopdf\\wkhtmltopdf.exe\" - - 2>dat/cc >dat/#{pdf_name}.pdf"
        # cmd = "\"c:\\Program Files\\wkhtmltopdf\\wkhtmltopdf.exe\" -q #{pdf_name}.html #{pdf_name}.pdf"
        if options[:javascript]
          cmd = "'wkhtmltopdf' --orientation #{options[:orientation]} --javascript-delay #{options[:javascript]} --margin-left 10 -q #{pdf_name}.html #{pdf_name}.pdf"
        else
          cmd = "'wkhtmltopdf' --orientation #{options[:orientation]} --margin-left 10 -q #{pdf_name}.html #{pdf_name}.pdf"
        end
        puts "******** "+cmd+" *******"
        #`#{cmd}`
          RAILS_DEFAULT_LOGGER.warn("\nVoi rula: #{cmd}\n\n")
        require 'open3'
        io = IO.popen(cmd)
        sleep 2
        #while !io.eof?
        #  io.read
        #  puts "."
        #end
        io.close

        #File.open(options[:save_to_file], 'wb') {|file| file << pdf_content } if options[:save_to_file]
        # send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
        send_file "#{pdf_name}.pdf"
      end
    end

    # Given an options hash, prerenders content for the header and footer sections
    # to temp files and return a new options hash including the URLs to these files.
    def prerender_header_and_footer(options)
      [:header, :footer].each do |hf|
        if options[hf] && options[hf][:html] && options[hf][:html][:template]
          WickedPdfTempfile.open("wicked_pdf.html") do |f|
            f << render_to_string(:template => options[hf][:html][:template],
                                  :layout => options[:layout])
            options[hf][:html].delete(:template)
            options[hf][:html][:url] = "file://#{f.path}"
          end
        end
      end

      return options
    end
end
