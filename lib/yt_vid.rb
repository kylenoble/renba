require "nokogiri"
require "mechanize"
require 'open-uri'
require 'addressable/uri'

module YtVid

  # Google search tips
  # OR range etc https://support.google.com/websearch/answer/136861?hl=en
  # punctuation: https://support.google.com/websearch/answer/2466433

  def self.query(search, filters = "") # Returns an Array of Hash results
    results = Mechanize.new.
      tap { |i| i.follow_meta_refresh = true }.
      get("https://www.youtube.com/results?search_query=#{Addressable::URI.parse(search).normalize + filters}")
    results.parser.css("ol.item-section > li")[1..-1].map do |result|
      {
        title: result.css("div:nth-child(1)").css("div:nth-child(2)").css("h3").text,
        video: result.css("div:nth-child(1)").css("div:nth-child(2)").css("h3 > a").first[:href].dup.tap{|i|i.replace i[(i.index("=").to_i+1)..-1]},
        views: Integer(String(/(\d+)/.match(result.css("div:nth-child(1)").css("div:nth-child(2)").css("li:nth-child(3)").text.gsub(",", "")))),
        new: !!result.css("div:nth-child(1)").css("div:nth-child(2)").css("div:nth-child(4)").css("ul:nth-child(1)").text["New"],
        hd: !!result.css("div:nth-child(1)").css("div:nth-child(2)").css("div:nth-child(4)").css("ul:nth-child(1)").text["HD"],
        description: result.css("div:nth-child(1)").css("div:nth-child(2)").css("div:nth-child(3)").text,
        length: result.css("div:nth-child(1)").css("div:nth-child(1)").css("a:nth-child(1)").css("span:nth-child(2)").text
      }
    end
  end

  def self.old_query(search) # Returns array of ['video title', 'vidoecode11']
    Mechanize.new.
        tap { |i| i.follow_meta_refresh = true }.
        get("https://www.youtube.com/results?search_query=#{Addressable::URI.parse(search).normalize}").
      links.
      select {|v| v.href["/watch?v="]}.
      delete_if {|v| v.text["\n"]}.
      map {|v| [v.text,v.href[(v.href.index("=")+1)..-1]]}
  end

  def self.vid_stats(video_code) # Video page hit.  Views are rounded to nearest thousand.
    x = Nokogiri::HTML(open("https://www.youtube.com/watch?v=#{video_code}"))
    {
      video: video_code,
      user_name: x.css('a.yt-user-name').text,
      description: x.css('p#eow-description').text,
      category: x.css('li.watch-meta-item:nth-child(1)').css('ul:nth-child(2)').css('li:nth-child(1)').css('a:nth-child(1)').first[:href].try(:[], 1..-1),
      views: String(/(\d+)/.match(x.css('div.watch-view-count').text.strip.gsub(',', ''))).to_i*1000,
      likes: String(/(\d+)/.match(x.css('button#watch-like').text.strip.gsub(',', ''))).to_i*1000,
      dislikes: String(/(\d+)/.match(x.css('button#watch-dislike').text.strip.gsub(',', ''))).to_i*1000,
      published: x.css('strong.watch-time-text').text[13..-1],
      license: x.css('li.watch-meta-item:nth-child(2)').text.gsub("\n", '').strip.tap {|i| i.replace i[i.index(' ').to_i..-1].strip}
    }
  end

  # https://developers.google.com/youtube/player_parameters
  # Recommended included options
  # {:embed => true, :autoplay => true, :origin => request.env["REQUEST_URI"]}

  def self.string_to_url(video_code, options = {})
    options.default = false
    parameters = "?"
    parameters.define_singleton_method(:ingest) {|item| self.<<("&") unless self[-1]["?"]; self.replace self.<<(item) }

    parameters.ingest("autoplay=1") if options[:autoplay]
    if options[:showplay]
      parameters.ingest("autohide=2")
    elsif options[:autohide]
      parameters.ingest("autohide=1")
    elsif options[:nohide]
      parameters.ingest("autohide=0")
    end
    parameters.ingest("cc_load_policy=1") if options[:cc]
    parameters.ingest("color=white") if options[:color] and !options[:modestbranding]
    parameters.ingest("controls=0") if options[:nocontrols]
    parameters.ingest("disablekb=1") if options[:nokeyboard]
    parameters.ingest("enablejsapi=1") if options[:jsapi]
    parameters.ingest("end=#{options[:end]}") if options[:end]
    parameters.ingest("fs=0") if options[:nofullscreen]
    # hl
    parameters.ingest("iv_load_policy=3") if options[:noanotate]
    # list
    # listType
    parameters.ingest("loop=1") if options[:loop]
    parameters.ingest("modestbranding=1") if options[:noytlogo]
    parameters.ingest("origin=http://#{URI.parse(options[:origin]).host}") if options[:origin]
    # playerapiid
    # playlist
    parameters.ingest("playsinline=1") if options[:playinline]
    parameters.ingest("rel=0") if options[:norelated]
    parameters.ingest("showinfo=0") if options[:hideinfo]
    parameters.ingest("start=#{options[:start]}") if options[:start]
    parameters.ingest("theme=light") if options[:lighttheme]

    parameters=("") if parameters.length.==(1)

    if options[:short]
      "http://youtu.be/#{video_code}".<<(parameters).html_safe
    elsif options[:embed]
      "//www.youtube.com/embed/#{video_code}".<<(parameters).html_safe
    else
      "https://www.youtube.com/watch?v=#{video_code}".<<(parameters.gsub("?","&")).html_safe
    end
  end

end