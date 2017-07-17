class ExerciseItemsController < InheritedResources::Base
  load_and_authorize_resource :exercise
  load_and_authorize_resource :exercise_item, :through => :exercise
  respond_to :json

  def remove_audio
    exercise_item = process_deletions
    exercise_item.remove_audio!

    if exercise_item.save!
      flash[:notice] = "Audio file removed"
    else
      flash[:error] = "Audio file not removed"
    end
    redirect_to edit_drill_path(exercise_item.exercise.drill)
  end

  def remove_image
    exercise_item = process_deletions
    exercise_item.remove_image!

    if exercise_item.save!
      flash[:notice] = "Image file removed"
    else
      flash[:error] = "Image file not removed"
    end
    redirect_to edit_drill_path(exercise_item.exercise.drill)
  end

  def remove_video
    exercise_item = process_deletions
    exercise_item.remove_video!

    if exercise_item.save!
      flash[:notice] = "Video file removed"
    else
      flash[:error] = "Video file not removed"
    end
    redirect_to edit_drill_path(exercise_item.exercise.drill)
  end

private

  def process_deletions
    exercise_item = ExerciseItem.find(params[:exercise_item_id])
    # Remove from Kaltura
    DeleteSingleFile.new(exercise_item.media_id, exercise_item.media_type).delete
    # Clear local DB columns
    exercise_item['media_id'] = ''
    exercise_item['media_type'] = ''

    exercise_item
  end
end
