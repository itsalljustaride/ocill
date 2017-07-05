module ExercisesHelper
  def graded_fill_drill_exercise(exercise, responses)
    spans = exercise.exercise_items.map do |ei|
      # TODO reduce number of sql queries
      if response = responses.find {|r| r.exercise_item_id.to_i == ei.id }
        '<span class="' + graded_class(response) + '">'  + response.value.to_s + '</span>' + " " + (response.correct? ? icon("ok") : icon("times"))
      else
        '<span class="left-blank"></span>' + icon("times")
      end
    end
    html = exercise.prompt_with_hints.gsub(/\[/,'{{').gsub(/\]/,'}}')
    spans.each {|span| html.sub!(/\{\{.+?\}\}/, span) }
    html
  end

  def graded_drag_drill_exercise(exercise, responses)

  end

  def graded_class(response)
    graded_class = "incorrect"
    graded_class = "correct" if response.correct?
    graded_class = "left-blank" if response.value.blank?
    graded_class
  end

  def graded_grid_drill_exercise(exercise, responses)
    html = ""
    exercise.exercise_items.each do |ei|
      if ei.answers
        response = responses.find {|r| r.exercise_item_id.to_i == ei.id }
        html += "<td>" + (response.correct? ? icon("ok") : icon("times")) + "</td>"
      else
        html += "<td>--</td>".html_safe
      end
    end
    html.html_safe
  end

  def edit_fill_drill_exercise(exercise, responses, attempt_id)
    inputs = exercise.exercise_items.map do |ei|
      response = responses.find {|r| r.exercise_item_id.to_i == ei.id }
      create_response_input(ei.id, attempt_id)
    end
    prompt = exercise.prompt_with_hints.gsub(/\[/,'{{').gsub(/\]/,'}}')
    inputs.each {|input| prompt.sub!(/\{\{.+?\}\}/, input) }
    prompt
  end

  def attempt_drag_drill_exercise(exercise, responses, attempt_id )

    inputs = exercise.exercise_items.map do |ei|
      if response = responses.find {|r| r.exercise_item_id.to_i == ei.id }
        create_response_input(ei.id, attempt_id, "text", "correct", response.value)
      end
    end
  end

  def attempt_fill_drill_exercise(exercise, responses, attempt_id)
    inputs = exercise.exercise_items.map do |ei|
      if response = responses.find {|r| r.exercise_item_id.to_i == ei.id }
        create_response_input(ei.id, attempt_id, "text", "correct", response.value)
      else
        response = Response.new( {exercise_item_id:ei.id, attempt_id: @attempt.id, value:''} )
        @attempt.responses += [response]
        create_response_input(ei.id, attempt_id)
      end
    end
    prompt = exercise.prompt_with_hints.gsub(/\[/,'{{').gsub(/\]/,'}}')
    inputs.each {|input| prompt.sub!(/\{\{.+?\}\}/, input) }
    prompt
  end

  def create_response_input(exercise_item_id, attempt_id, type="text", css_class="the_blank", value="" )
    i = rand(1...999999999)
    '
      <input id="attempt_responses_exercise_item_id" name="attempt[responses][' + i.to_s + '][exercise_item_id]" type="hidden" value="' + exercise_item_id.to_s + ' "/>

      <input class="' + css_class + '" id="attempt_responses_value" name="attempt[responses][' + i.to_s + '][value]" type="' + type + '" value="' + value + '"/>
    '
  end

  def create_grid_drill_exercises(exercise, responses)

    inputs = exercise.exercise_items.map do |ei|
      if response = responses.select {|r| r.exercise_item_id == ei.id}.first
        input = "<td class=\"finished-playing\">"
        input += create_response_input(ei.id, response.id, "hidden", "audio-played", response.value)
      else
        input= "<td>"
        response = Response.new({"exercise_item_id" => ei.id})
        input += create_response_input(ei.id, 80085, "hidden", "audio-played", "0" )
      end
        input += audio_tag(ei.audio_urls) unless ei.audio_url.blank? || ei.audio_url.include?("fallback")
        input += image_tag(exercise.image_url(:small)) unless exercise.image.blank? || exercise.image_url.include?("fallback")
        text = ei.text unless exercise.drill.hide_text?
        input += content_tag(:p, text )
        input += "</td>"
    end
    inputs.join('')
  end

  def kaltura_image_display(model)
    return unless model.media_type == Exercise::IMAGE
    unless model.media_id.blank? || model.image_url.include?("fallback")
      host = Exercise::HOST
      partner_id = Exercise::PARTNER_ID
      media_id = model.media_id
      image_tag "http://#{host}/p/#{partner_id}/sp/#{partner_id}00/raw/entry_id/#{media_id}/version/100001"
    end
  end

  def kaltura_audio_player(model)
    return unless model.media_type == Exercise::AUDIO
    unless model.media_id.blank? || model.audio_url.include?("fallback")
      host = Exercise::HOST
      partner_id = Exercise::PARTNER_ID
      player_id = Exercise::AUDIO_PLAYER_ID
      media_id = model.media_id
      player_width = 400
      player_height = 100
      s = "<script src='https://#{host}/p/#{partner_id}/sp/#{partner_id}00/embedIframeJs/uiconf_id/#{player_id}/partner_id/#{partner_id}?autoembed=true&entry_id=#{media_id}&playerId=#{player_id + media_id}&width=#{player_width}&height=#{player_height}'></script>"
      raw(s)
    end
  end

  def kaltura_video_player(model)
    return unless model.media_type == Exercise::VIDEO
    unless model.media_id.blank? || model.video_url.include?("fallback")
      host = Exercise::HOST
      partner_id = Exercise::PARTNER_ID
      player_id = Exercise::VIDEO_PLAYER_ID
      media_id = model.media_id
      player_width = 400
      player_height = 330
      s = "<script src='https://#{host}/p/#{partner_id}/sp/#{partner_id}00/embedIframeJs/uiconf_id/#{player_id}/partner_id/#{partner_id}?autoembed=true&entry_id=#{media_id}&playerId=#{player_id + media_id}&width=#{player_width}&height=#{player_height}'></script>"
      raw(s)
    end
  end

  def deletable_object?(model, type)
    model.id && model['media_type'] == type
  end

end
