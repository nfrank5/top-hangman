require 'yaml'

module Graphics
  def clear_screen
    system('cls') || system('clear')
  end

  def draw(drawing_current_index)
    drawing = "______\n      |\n      O\n     /|\\\n     / \\\n"
    drawing_indexes_array = [14, 20, 23, 29, 30, 31, 38, 40]
    puts "#{drawing[0, drawing_indexes_array[drawing_current_index]]}\n \n"
  end

  def board
    clear_screen
    puts "#{@word.hidden_word} \n(The word has #{@word.letters_count} letters.)"
    puts "You have #{7 - @fails} #{7 - @fails == 1 ? 'guess' : 'guesses'} left"
    puts "Your wrong guesses: #{@previous_letters}"
  end
end

module Data
  def save_games
    ans = string_input('Do you want to save the game?(Y/N)', /^[yn]$/)
    if(ans == 'y')
      game_name = string_input('Enter a name to save the game(Lowercase, 3 to 10 letters): ', /^[a-zA-Z]{3,10}$/)
      file = File.open("saved_games/#{game_name}.yml", 'w')
      file.puts YAML.dump({
        word: @word, 
        fails: @fails,
        previous_letters: @previous_letters 
      })
      file.close
      puts "The game was saved with the name: #{game_name}\nThank you for playing"
    end
    ans == 'y'
  end

  def load_game
    ans = string_input('Do you want to load a saved Game?(Y/N)', /^[yn]$/)
    return unless ans == 'y'
    
    Dir.glob('*/*.yml').each do | file | 
      puts file.split('/')[1].split('.')[0]
    end
    game_name = gets.chomp

    Dir.glob('*/*.yml').each do | file | 
      if(file == "saved_games/#{game_name}.yml")
        file = YAML.load_file("saved_games/#{game_name}.yml", permitted_classes: [Symbol, Word])
        @word = file[:word]
        @fails = file[:fails]
        @previous_letters = file[:previous_letters]
        break
      end
    end

    ans == 'y'
  end

  def string_input(message, regex)
    str = ''
    until str.downcase.match(regex)
      puts message
      str = gets.chomp
    end
    str
  end
end

class Word

  attr_reader :word, :letters_count, :hidden_word

  def initialize
    @word = prepare_word
    @letters_count = @word.length
    @hidden_word = @word.gsub(/[a-z]/, '-')
  end

  def prepare_word()
    random_word_index = rand(0..10_000)
    word = ''
    File.open('google-10000-english-no-swears.txt', 'r') do |file|
      words = file.readlines
      until words[random_word_index].chomp.length >= 5 && words[random_word_index].chomp.length <= 12 do
        random_word_index = rand(0..10_000)
      end
      word = words[random_word_index].chomp
    end
    word
  end
end

class Game
  include Graphics
  include Data
  
  def initialize
    @word = Word.new
    @fails = 0
    @previous_letters = []
  end

  def player_input
    guess_letter = string_input('Please insert one letter: ', /^[a-zA-Z]$/)
    indexes_guess_letter = (0...@word.word.length).find_all { |i| @word.word[i,1] == guess_letter }
    @word.hidden_word.split('').each_with_index do |dash, i|
      if indexes_guess_letter.include? i
        @word.hidden_word[i] = guess_letter
      end
    end
    unless @word.word.include?(guess_letter)
      @fails += 1 
      @previous_letters.push(guess_letter)
    end
  end
  
  def play_game()
    puts 'Welcome to Hangman!'
    load_game

    while @word.hidden_word.include?('-') do
      board
      draw(@fails) if @fails.positive?
      break unless @fails < 7
      return if save_games

      player_input
    end
    puts @fails < 7 ? 'Congratulations! You won!' : 'You lose...'
    puts "The word was: #{@word.word}\nThanks for playing!"
  end
end

new_game = Game.new
new_game.play_game