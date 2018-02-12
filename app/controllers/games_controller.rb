require 'open-uri'

class GamesController < ApplicationController
  def new
    # @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @letters = Array.new(3) { %w(A E I O U Y ).sample }.push(Array.new(7) { ('A'..'Z').to_a.sample }).flatten.shuffle
  end

  def score
    end_time = Time.now
    word = params[:word]
    letters = params[:letters]
    @result = run_game(word, letters, params[:start_time].to_datetime, end_time)
  end
end

private

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(attempt, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last
end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      ["Congratulations! #{attempt} is a valid English word!"]
    else
      ["Sorry but #{attempt} does not seem to be a valid English word..."]
    end
  else
    ["Sorry but #{attempt} can't be build out of #{grid}"]
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end
