module ApplicationHelper
  def link_to_add_fields(name, f, association, view_location=nil)
    new_object = f.object.send(association).klass.new
    id = (f.instance_variable_get("@nested_child_index").values[0] || 0).to_i
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      if view_location
        render(view_location, f: builder)
      else 
        render(association.to_s.singularize + "_fields", f: builder)
      end
    end
    classes = "add-fields btn btn-default add-fields-" + id.to_s
    link_to(name, '#', class: classes, data: {id: id, fields: fields.gsub("\n", "")}, type: "button")
  end

  def nested_folder(model, sub_folder=nil)
    folder = model.class.model_name.to_s.downcase.pluralize
    sub_folder ||= model.respond_to?(:type) ? model.type.to_s.underscore.pluralize : model.drill.type.to_s.underscore.pluralize
    '/' + folder + '/' + sub_folder + '/'
  end

  def nested_child_index(f)
    model = f.object.class.name.underscore.pluralize + "_attributes"
    attributes = f.object_name.scan(/(?<=\[)[^\]]+?(?=\])/)
    raise "nested_child_index couldn't find a matching attribute" unless attributes.index(model)
    index = attributes[attributes.index(model) + 1].to_i
  end
  
  def audio_tag(srcs, options ={})
    return "" unless srcs
    srcs = ["#{srcs}"] if srcs.class == String

    options[:error]  ||= "Your browser does not support the audio formats used by this application."    
    options[:preload] ||= "auto"
    
    audio = '<div class="audio-controls">'
    audio += "<audio preload=\"#{options[:preload]}\" controls>" 
    srcs.each {|src| audio += audio_source_tag(src)}    
    audio += "  #{options[:error]}"
    audio += "</audio>".html_safe
    audio += icon( "minus", 'white', ['audio-decelerate'] )
    audio += ' Speed: <span class="playback-speed">1.00</span>x'
    audio += icon( "plus", 'white', ['audio-accelerate'] )
    audio += '</div>'
    audio.html_safe
  end

  def cached_user_navigation
    CoursePermissions
    Rails.cache.fetch([current_user, "navigation-layout"]) do
      render partial: 'layouts/course_navigation', :layout => false, :collection => Course.includes(:units => :drills), as: :course
    end
  end

  def audio_source_tag(url)
    path_sans_ext = remove_audio_ext(url)
    filename = url.split("/").last
    ext = filename.split(".").last
    source = "<source src=\"#{url}\" type=\"#{mime_type_for(ext)}\" >"
  end

  def remove_audio_ext(path_and_file)
    path_and_file.sub(/\.ogg$|\.oga$|\.mp3$|\.wav$|\.m4a$/i, '')
  end

  def mime_type_for(ext)
    case ext
    when "m4a", "mp4"
      "audio/mp4"
    when "wav"
      "audio/wav"
    when "mp3"
      "audio/mpeg"
    when "oga", "ogg"
      "audio/ogg"
    else
      ""
    end
  end
  
  def video_tag(src, options ={})
    return "" unless src
    options[:preload] ||= "auto"
    options[:error]  ||= "Your browser does not support the mp3 audio format"
    options[:formats]  ||= ["mp4"]
    options[:classes] ||= ""
    html = "<video controls class=\"#{options[:classes]}\" preload=\"#{options[:preload]}\">"
    sources = options[:formats].each {|format| html += "<source src=\"#{src}.#{format}\" type=\"video/#{format}\">" }
    html += "options[:error]"
    html += "</video>"
    html.html_safe
  end

  def ul_tag(array, classes)
    html = "<ul class=\"" + classes.join(" ") + "\">"
    array.each do |el|
      html += "<li>" + el.to_s + "</li>"
    end
    html += "</ul>"
  end

  def icon(type, color='', classes=[])
    color = ' ' + color unless color.empty?
    if icons.include?("icon-" + type.to_s)
      icon = '<i class="fa fa-' + type.to_s + color + ' ' + classes.join(" ") + '"></i>'
    else
      icon = type.to_s
    end
    icon.html_safe
  end

  def link_to_add_exercise(name, f, association, view_location=nil)

    drill_id = f.object.id.to_s
    id = (f.instance_variable_get("@nested_child_index").values[0] || 0).to_i

    classes = "add-fields-remote btn btn-default add-fields-remote-" + id.to_s
    link_to(name, '#', class: classes, data: {id: id, drill_id: drill_id }, type: "button")
  end


  def icons
    %w{ icon-bars icon-glass icon-music icon-search icon-envelope-alt icon-heart icon-star icon-star-empty icon-user icon-film icon-th-large icon-th icon-th-list icon-ok icon-times icon-zoom-in icon-zoom-out icon-off icon-signal icon-cog icon-trash icon-home icon-file-alt icon-time icon-road icon-download-alt icon-download icon-upload icon-inbox icon-play-circle icon-repeat icon-refresh icon-list-alt icon-lock icon-flag icon-headphones icon-volume-off icon-volume-down icon-volume-up icon-qrcode icon-barcode icon-tag icon-tags icon-book icon-bookmark icon-print icon-camera icon-font icon-bold icon-italic icon-text-height icon-text-width icon-align-left icon-align-center icon-align-right icon-align-justify icon-list icon-indent-left icon-indent-right icon-facetime-video icon-picture icon-pencil icon-map-marker icon-adjust icon-tint icon-edit icon-share icon-check icon-move icon-step-backward icon-fast-backward icon-backward icon-play icon-pause icon-stop icon-forward icon-fast-forward icon-step-forward icon-eject icon-chevron-left icon-chevron-right icon-plus-sign icon-minus-sign icon-remove-sign icon-ok-sign icon-question-sign icon-info-sign icon-screenshot icon-remove-circle icon-ok-circle icon-ban-circle icon-arrow-left icon-arrow-right icon-arrow-up icon-arrow-down icon-share-alt icon-resize-full icon-resize-small icon-plus icon-minus icon-asterisk icon-exclamation-sign icon-gift icon-leaf icon-fire icon-eye-open icon-eye-close icon-warning-sign icon-plane icon-calendar icon-random icon-comment icon-magnet icon-chevron-up icon-chevron-down icon-retweet icon-shopping-cart icon-folder-close icon-folder-open icon-resize-vertical icon-resize-horizontal icon-bar-chart icon-twitter-sign icon-facebook-sign icon-camera-retro icon-key icon-cogs icon-comments icon-thumbs-up-alt icon-thumbs-down-alt icon-star-half icon-heart-empty icon-signout icon-linkedin-sign icon-pushpin icon-external-link icon-signin icon-trophy icon-github-sign icon-upload-alt icon-lemon icon-phone icon-check-empty icon-bookmark-empty icon-phone-sign icon-twitter icon-facebook icon-github icon-unlock icon-credit-card icon-rss icon-hdd icon-bullhorn icon-bell icon-certificate icon-hand-right icon-hand-left icon-hand-up icon-hand-down icon-circle-arrow-left icon-circle-arrow-right icon-circle-arrow-up icon-circle-arrow-down icon-globe icon-wrench icon-tasks icon-filter icon-briefcase icon-fullscreen icon-group icon-link icon-cloud icon-beaker icon-cut icon-copy icon-paper-clip icon-save icon-sign-blank icon-reorder icon-list-ul icon-list-ol icon-strikethrough icon-underline icon-table icon-magic icon-truck icon-pinterest icon-pinterest-sign icon-google-plus-sign icon-google-plus icon-money icon-caret-down icon-caret-up icon-caret-left icon-caret-right icon-columns icon-sort icon-sort-down icon-sort-up icon-envelope icon-linkedin icon-undo icon-legal icon-dashboard icon-comment-alt icon-comments-alt icon-bolt icon-sitemap icon-umbrella icon-paste icon-lightbulb icon-exchange icon-cloud-download icon-cloud-upload icon-user-md icon-stethoscope icon-suitcase icon-bell-alt icon-coffee icon-food icon-file-text-alt icon-building icon-hospital icon-ambulance icon-medkit icon-fighter-jet icon-beer icon-h-sign icon-plus-sign-alt icon-double-angle-left icon-double-angle-right icon-double-angle-up icon-double-angle-down icon-angle-left icon-angle-right icon-angle-up icon-angle-down icon-desktop icon-laptop icon-tablet icon-mobile-phone icon-circle-blank icon-quote-left icon-quote-right icon-spinner icon-circle icon-reply icon-github-alt icon-folder-close-alt icon-folder-open-alt icon-expand-alt icon-collapse-alt icon-smile icon-frown icon-meh icon-gamepad icon-keyboard icon-flag-alt icon-flag-checkered icon-terminal icon-code icon-reply-all icon-mail-reply-all icon-star-half-empty icon-location-arrow icon-crop icon-code-fork icon-unlink icon-question icon-info icon-exclamation icon-superscript icon-subscript icon-eraser icon-puzzle-piece icon-microphone icon-microphone-off icon-shield icon-calendar-empty icon-fire-extinguisher icon-rocket icon-maxcdn icon-chevron-sign-left icon-chevron-sign-right icon-chevron-sign-up icon-chevron-sign-down icon-html5 icon-css3 icon-anchor icon-unlock-alt icon-bullseye icon-ellipsis-horizontal icon-ellipsis-vertical icon-rss-sign icon-play-sign icon-ticket icon-minus-sign-alt icon-check-minus icon-level-up icon-level-down icon-check-sign icon-edit-sign icon-external-link-sign icon-share-sign icon-compass icon-collapse icon-collapse-top icon-expand icon-eur icon-gbp icon-usd icon-inr icon-jpy icon-cny icon-krw icon-btc icon-file icon-file-text icon-sort-by-alphabet icon-sort-by-alphabet-alt icon-sort-by-attributes icon-sort-by-attributes-alt icon-sort-by-order icon-sort-by-order-alt icon-thumbs-up icon-thumbs-down icon-youtube-sign icon-youtube icon-xing icon-xing-sign icon-youtube-play icon-dropbox icon-stackexchange icon-instagram icon-flickr icon-adn icon-bitbucket icon-bitbucket-sign icon-tumblr icon-tumblr-sign icon-long-arrow-down icon-long-arrow-up icon-long-arrow-left icon-long-arrow-right icon-apple icon-windows icon-android icon-linux icon-dribbble icon-skype icon-foursquare icon-trello icon-female icon-male icon-gittip icon-sun icon-moon icon-archive icon-bug icon-vk icon-weibo icon-plus-square icon-minus-square}
  end
end
