require 'erb'
require 'yaml'
class Hangman
    @@word_bank = File.read('google-10000-english-no-swears.txt')
    @@word_bank_array = @@word_bank.split(" ")
    @@acceptable_word_bank_array = @@word_bank_array.select { |word| word.length > 4 && word.length < 13}

    def initialize
        @number_of_guesses_left = 6
        @array_of_wrong_guesses = []
    end
    
    def reveal_letters(string, letter, clone_array)
        first_array = string.split("")
        first_array.each_with_index do |item, index|
            if first_array[index] == letter
                clone_array[index] = letter
            end
        end
    end


    def start
        puts "Welcome! Press 1 to start a new game. Press 2 to load a saved game."
        choice = gets.chomp.to_i
        @word_to_guess = @@acceptable_word_bank_array.sample
        @correct_guesses_array = Array.new(@word_to_guess.length, 0)
        if choice == 2
            puts "Enter the name of your save file"
            name = gets.chomp
            file = YAML.load(File.open(File.join(File.dirname(__FILE__), "/saved_games/#{name}.yaml")))
            @word_to_guess = file[:word]
            @correct_guesses_array = file[:correct_guesses]
            @number_of_guesses_left = file[:guesses_left]
            @array_of_wrong_guesses = file[:incorrect_guesses]
        end
        while @number_of_guesses_left > 0 && @correct_guesses_array != @word_to_guess.split("")
            puts "Pick a letter to guess, or type save to save this game"
            selection = gets.chomp.downcase
            if selection == 'save'
                puts "Please choose a name for your save file"
                name = gets.chomp
                file = {
                    word: @word_to_guess,
                    correct_guesses: @correct_guesses_array,
                    guesses_left: @number_of_guesses_left,
                    incorrect_guesses: @array_of_wrong_guesses,
                }        
                File.open(File.join(Dir.pwd, "/saved_games/#{name}.yaml"), 'w')  { |f| f.write(YAML.dump(file)) }
                puts "File Saved Successfully!"
                break
            elsif @word_to_guess.split("").include?(selection)
                reveal_letters(@word_to_guess, selection, @correct_guesses_array)
            else
                if @array_of_wrong_guesses.include?(selection)
                    puts "You already guessed that letter, try again"
                else
                    @number_of_guesses_left -= 1
                    @array_of_wrong_guesses.push(selection)
                end
            end
            p @correct_guesses_array
            puts "Incorrect guesses: "
            p @array_of_wrong_guesses
            puts "You have #{@number_of_guesses_left} wrong guesses left."
        end
        if @number_of_guesses_left > 0 && @correct_guesses_array == @word_to_guess.split("")
            puts "Congratulations! You correctly guessed the word #{@word_to_guess}!"
        else
            puts "Sorry, the correct word was #{@word_to_guess}"
        end
    end

end
game = Hangman.new()
game.start
