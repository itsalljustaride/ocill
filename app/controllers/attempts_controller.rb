class AttemptsController < InheritedResources::Base
  load_and_authorize_resource

  def new
    if params[:drill_id]
      @attempt = current_user.attempts.new(:drill_id => params[:drill_id])
      @drill = Drill.includes(:exercises => :exercise_items).find(params[:drill_id])
      old_responses = []

      if @drill.retain_correct?
        attempts_on_this_drill = current_user.attempts.where(:drill_id => params[:drill_id]).order("created_at DESC")
        if attempts_on_this_drill.count > 0
          latest = attempts_on_this_drill.first
          old_responses = latest.correct_responses
        end
      end

      new_responses_needed = @drill.exercise_items.count - old_responses.count || 1
      @attempt.responses += Responses.new(new_responses_needed)
      @attempt.responses += Responses.new(old_responses)
      respond_with @attempt
    else
      not_found 'There is no drill here for you attempt'
    end
  end

  def create
    if params[:drill_id]
       @attempt = current_user.attempts.new(:drill_id => params[:drill_id])
        params[:attempt][:responses].each do |id, response|
          @attempt.responses+= [ Response.new(response) ]
        end
      if @attempt.save
        if current_user.is_lti? && @tool && @tool.outcome_service?
          score = @attempt.decimal_score
          result = @tool.post_replace_result!(score)
          if result.success?
            flash[:notice] = "Your score was submitted as #{score*100}%"
          else
            flash[:alert] = "Your score was not submitted.  Please notify OCILL support of the problem."
          end
        else
          flash[:notice] = "Successfully saved your attempt."
        end
        respond_to do |format|
          format.html {
            respond_with @attempt
          }
          format.json {
            render json: @attempt
          }
        end
      else
        flash[:error] = "Failed to save your attempt."
      end
    else
      not_found 'There is no drill to create an attempt for.'
    end
  end

  def show
    @attempt = Attempt.includes([:drill, :exercise_items] ).find(params[:id])
    @exercise_items = @attempt.exercise_items
    @responses = @attempt.responses
    @drill =  @attempt.drill || Drill.find(params[:drill_id])
  end

  def update
    super do |format|
      if current_user.is_lti? && @tool && @tool.outcome_service?
        score = @attempt.decimal_score
        result = @tool.post_replace_result!(score)
        if result.success?
          flash[:notice] = "Your score was submitted as #{score*100}%"
        else
          flash[:alert] = "Your score was not submitted.  Please notify OCILL support of the problem."
        end
      end
      format.html { redirect_to drill_attempt_path(@attempt)  }
    end

  end
end
