class ExercisesController < InheritedResources::Base
  load_and_authorize_resource :drill
  load_and_authorize_resource :exercise, :through => :drill
  respond_to :html, :json
  
  def new
    @drill = Drill.find(params[:drill_id])
    @exercise = Exercise.new(drill_id: params[:drill_id])
    respond_to do |format|
      format.html { redirect_to proc { edit_drill_url(@drill, @exercise) } }
      format.js
    end
  end

  def remove_audio
    exercise = Exercise.find(params[:exercise_id])
    exercise.remove_audio!
    if exercise.save!
      flash[:notice] = "Audio file removed"
    else
      flash[:error] = "Audio file not removed"
    end
    redirect_to edit_drill_path(exercise.drill)
  end

  def remove_image
    exercise = Exercise.find(params[:exercise_id])
    exercise.remove_image!
    if exercise.save!
      flash[:notice] = "Image file removed"
    else
      flash[:error] = "Image file not removed"
    end
    redirect_to edit_drill_path(exercise.drill)
  end

end
