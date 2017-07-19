class DragDrill < Drill

  def self.model_name
    Drill.model_name
  end

  def as_json(options={})
    data = {}
    options[:order] = response_order(options[:current_user])

    if options[:type] == :shuffle || options[:type] == :simple
      data = {
        id: self.id,
        unit_id: self.unit_id ,
        exercises: self.exercises.as_json(options),
        options:  self.options,
        title: self.title
      }
    else
      data = {
        id: self.id ,
        instructions: self.instructions ,
        prompt: self.prompt ,
        position: self.position ,
        options:  self.options ,
        title: self.title ,
        unit_id: self.unit_id ,
        exercises: self.exercises.as_json(options)
      }
    end
    data
  end

  def response_order current_user
    if current_user.attempts.last.responses
      current_user.attempts.last.responses.map{|r| r.exercise_item_id.to_i} unless current_user.nil?
    end
  end

end
