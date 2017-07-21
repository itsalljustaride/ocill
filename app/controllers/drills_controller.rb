class DrillsController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json

  def show
    @drill = Drill.find(params[:id])
  end

  def read
    @drill = Drill.includes( exercises: :exercise_items ).find(params[:drill_id])
    options = {}
    options[:type] = params[:type].to_sym
    options[:current_user] = current_user
    # needs to shuffle first time round
    options[:first_attempt] = request.referrer.split('/').include?('new') unless request.referrer.blank?

    respond_to do |format|
      format.html
      if params[:type]
        format.json { render json: @drill.as_json(options) }
      else
        format.json { render json: @drill.as_json }
      end
     # format.json { render json: @drill.as_json }
    end
  end

  def new
    if params[:unit_id]
      @unit = Unit.find(params[:unit_id])
      @drill = @unit.drills.build

    else
      @drill = Drill.new
    end
  end

  def index

  end

  def create
    if @drill.type == "DragDrill"

      if @drill.save
        redirect_to edit_drill_url(@drill)
        return
      end
    end

    super do |format|
      format.html { render :action => "edit" }
    end

  end


  def update
    @drill = Drill.find(params[:id])
    has_exercises = @drill.exercises.count > 0 ? true : false
    add_answers_to_params unless current_user.is_learner?

    if @drill.update_attributes(params[:drill])
      update_drag_exercise_positions(has_exercises)
      update_drag_exercise_item_positions(has_exercises)
      flash[:notice] = "Successfully updated the drill."
    end
    respond_with(@drill) do |format|
      format.html { render :action => "edit" }
      format.json { render json: @drill.as_json }
    end
  end

  def destroy
    @drill = Drill.find(params[:id])
    unit = @drill.unit
    @drill.destroy
    super do |format|
      format.html { redirect_to unit_url(unit) }
    end
  end

  def add_column
    @drill = Drill.find(params[:id])
    if @drill.update_attributes(params[:drill])
      flash[:notice] = "Drill Updated."
      if @drill.add_column
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
          format.js
        end
      else
        flash[:error] = "Drill Was Not Updated."
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
        end
      end
    else
      flash[:error] = "Drill Update Failed."
    end

  end

  def add_row
    @drill = Drill.find(params[:id])
    if @drill.update_attributes(params[:drill])
      if @row = @drill.add_row
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
        end
      end
    else
      flash[:error] = "Drill Was Not Updated."
      respond_to do |format|
        format.html { redirect_to(:action => 'edit') }
      end
    end
  end

  def remove_row
    @drill = Drill.find(params[:id])
    if @drill.update_attributes(params[:drill])
      if @row = @drill.remove_row(params[:exercise_id])
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
        end
      end
    else
      flash[:error] = "Drill Was Not Updated."
      respond_to do |format|
        format.html { redirect_to(:action => 'edit') }
      end
    end
  end

  def remove_column
    @drill = Drill.find(params[:id])
    if @drill.update_attributes(params[:drill])
      if @drill.remove_column(params[:header_id])
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to(:action => 'edit') }
        end
      end
    else
      flash[:error] = "Drill Was Not Updated."
      respond_to do |format|
        format.html { redirect_to(:action => 'edit') }
      end
    end
  end

private

  def add_answers_to_params
    exercises_attr = params['drill']['exercises_attributes']
    return if exercises_attr.nil?

    # Iterate each exercise
    exercises_attr.each_with_index do |attrs, index|
      return unless attrs && attrs.last['exercise_items_attributes']

      new_items = {}
      exercises_items_attr = attrs.last['exercise_items_attributes']

      # Process exercise items
      exercises_items_attr.each_with_index do |item, i|
        new_items[i.to_s] = exercises_items_attr[i.to_s].merge({'acceptable_answers' => [i]})
      end

      attrs.last['exercise_items_attributes'] = new_items
    end
  end

  def update_drag_exercise_positions(has_exercises)
    return unless @drill.type == Drill::DRAG_DRILL
    return if params['drill']['exercises_attributes'].nil?

    current_positions = @drill.exercises.map{|e| [e.id.to_s, e.position.to_s]}.to_h
    if has_exercises
      incoming_positions = params['drill']['exercises_attributes'].map{|ea| [ea[1]['id'], ea[0] ] }.to_h
    else
      incoming_positions = current_positions.each_with_index.map{|k, i| [k.first, i] }.to_h
    end

    ids_to_update = incoming_positions.map{|k,v| k }
    values_to_update = incoming_positions.map{|k,v| { position: v }}
    Exercise.update(ids_to_update, values_to_update) # unless current_positions == incoming_positions
  end

  def update_drag_exercise_item_positions(has_exercises)
    return unless @drill.type == Drill::DRAG_DRILL
    return if params['drill']['exercises_attributes'].nil?

    @drill.exercises.each_with_index do |exercise, i|
      break if params['drill']['exercises_attributes']["#{i}"].nil?
      ex_items = params['drill']['exercises_attributes']["#{i}"]['exercise_items_attributes']

      incoming_positions = ex_items.map{|ei| [ ei[1]['id'], ei[0] ] }.to_h
      ids_to_update = incoming_positions.map{|k,v| k }
      values_to_update = incoming_positions.map{|k,v| { position: v }}
      puts ids_to_update
      ExerciseItem.update(ids_to_update, values_to_update)
    end
  end

end
