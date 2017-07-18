class Attempt < ActiveRecord::Base
  attr_accessible :drill_id, :user_id, :lis_outcome_service_url, :lis_result_sourcedid, :response, :responses

  has_many :exercise_items, :through => :drill
  belongs_to :drill
  belongs_to :user
  default_scope :include => :exercise_items
  serialize :response, JSON

  # TODO move the presentation of the score out of the model and into a view helper
  def html_score
    '<span class="score"><span class="correct">' + correct.to_s + '</span>/<span class="total">' + total.to_s + '</span></span>'.html_safe
  end

  def responses
    self.response = Responses.new(self.response || 0)
  end

  def responses=(*args)
    self.response = Responses.new(*args)
  end

  def matches_current_drill_state?
    broken_responses = self.responses.select do |r|
      !self.exercise_item_ids.include?(r.exercise_item_id.to_i)
    end
    broken_responses.empty?
  end

  def decimal_score
    (correct.to_f / total.to_f).round(2)
  end

  #TODO: use or remove
  def percent_score
    return 0 if total == 0
    correct / total
  end

  def correct_responses
    responses.select {|response| correct_ids.include?(response.exercise_item_id)}
  end

  def correct
    correct_ones.count
  end

  def course
    self.drill.course
  end

  def incorrect
    total - correct
  end

  def total
    grade_sheet.select { |el| el[1].present? }.count
  end

  def answers
    responses.map{ |r| r.exercise_item.answers}.flatten
  end

  def grade_sheet
    data = []
    type = Drill.find(drill_id).type

    case type
    when Drill::DRAG_DRILL
      acceptable_answers = {}

      exercises = responses.map{|r| r.exercise_item.exercise }.uniq
      exercises.each_with_index do |exercise, i|
        answers = exercise.exercise_items.map {|ei| [ei.id, ei.acceptable_answers.first] }.to_h
        acceptable_answers.merge!(answers)
      end

      responses.map do |response|
        answer = acceptable_answers[response['exercise_item_id'].to_i]
        data << [response.value, answer.to_s, response.exercise_item_id]
      end
    else
      responses.each_with_index.map do |response, index|
        answers = response.exercise_item ? response.exercise_item.answers : []
        data << [response.value, answers, response.exercise_item_id]
      end
    end

    data
  end

  def correct_ones
    grade_sheet.select do |el|
      el[1].include?(el[0].to_s) if el[1].respond_to?(:include?)
    end
  end

  def self.grade_dragdrill(responses)
    results = {}
    mistakes = []
    exercises = responses.map{|r| r.exercise_item.exercise }.uniq
    user_answers = responses.map {|r| [r["exercise_item_id"], r["value"]] }.to_h

    exercises.each do |exercise|
      correct_answers = exercise.exercise_items.map {|ei| [ei.id.to_s, ei.acceptable_answers] }.to_h

      correct_answers.each do |ans|
        accepted_answer_arr = ans.last
        user_answer = user_answers[ans.first].to_i

        unless accepted_answer_arr.include?(user_answer)
          mistakes << exercise.id
          break
        end
      end
    end

    results[:total] = exercises.count
    results[:correct] = exercises.count - mistakes.count
    results
  end

  def correct_ids
    correct_ones.map {|array| array[2] }
  end

  def exercise_item_ids
    self.exercise_items.map { |ei| ei['id']  }
  end
end
