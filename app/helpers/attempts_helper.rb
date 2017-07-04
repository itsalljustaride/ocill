module AttemptsHelper

  def label_by_model(model_class, label)
    "#{model_class.human_attribute_name(label)}:"
  end

  def process_dragdrill(results)
    correct = results[:correct].to_s
    total = results[:total].to_s

    display_score(correct, total)
  end

  def score_attempt(attempt)
    correct = 0
    total = 0

    # default 0/0 score for drills that don't report a grade
    unless attempt.responses.blank?
      correct = attempt.correct.to_s
      total = attempt.total.to_s
    end

    display_score(correct, total)
  end

  def display_score(correct, total)
    raw "<span class='score'><span class='correct'>#{correct}</span>/<span class='total'>#{total}</span></span>"
  end

end
