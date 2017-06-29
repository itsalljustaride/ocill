module AttemptsHelper

  def score_attempt attempt
    correct = 0
    total = 0

    # default 0/0 score for drills that don't report a grade
    unless attempt.responses.blank?
      correct = attempt.correct
      total = attempt.total
    end

    # raw '<span class="score"><span class="correct">' + correct + '</span>/<span class="total">' + total + '</span></span>'
    raw "<span class='score'><span class='correct'>#{correct.to_s}</span>/<span class='total'>#{total.to_s}</span></span>"
  end

end
