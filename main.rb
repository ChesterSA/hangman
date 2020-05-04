require 'benchmark'

class Hangman
  @master_words
  @master_letters

  # @return [Hash{Symbol->Integer}] An array of letters with how many words they occur in
  # @param [String] file # the text file to load words from
  def initialize(file = 'words.txt')
    @master_words = File.open(file).readlines.map(&:chomp)
    letters = {
      a: 0,
      b: 0,
      c: 0,
      d: 0,
      e: 0,
      f: 0,
      g: 0,
      h: 0,
      i: 0,
      j: 0,
      k: 0,
      l: 0,
      m: 0,
      n: 0,
      o: 0,
      p: 0,
      q: 0,
      r: 0,
      s: 0,
      t: 0,
      u: 0,
      v: 0,
      w: 0,
      x: 0,
      y: 0,
      z: 0
    }

    letters.update(letters) do |letter, value|
      @master_words.each do |word|
        value += 1 if word.include? letter.to_s
      end
      value
    end
    @master_letters = letters
  end

  # @param [Object] display If true, will put working strings to the console
  # @return [Hash{null->null}]  A hash of every word with how many guesses it took
  def full_search_simple(display = false)
    output = {}

    @master_words.each do |hangman|
      output[hangman] = guess_simple(hangman, display)
    end
    if display
      output.each do |k, v|
        puts k if v == 26
      end
    end
    # puts output.inspect
    output
  end

  # @param [Object] hangman the word that needs guessing
  # @param [Object] display if true the method will print it's working to the console
  # @return [Integer] THe amount of guesses taken to guess the word
  def guess_simple(hangman, display = false)
    letters = @master_letters.clone

    temp = hangman.clone
    guess = ''
    temp.split('').each do
      guess += '_'
    end

    guesses = 0
    incorrect = 0
    while guess != hangman
      letter = letters.key(letters.values.max)
      puts "Guessing #{letter}" if display

      if temp.include? letter.to_s
        puts 'Correct!' if display
        while temp.include? letter.to_s
          i = temp.index(letter.to_s)
          temp[i] = '.'
          guess[i] = letter.to_s
        end
      else
        puts "Incorrect: #{11 - incorrect} lives remaining" if display
        incorrect += 1
      end

      letters.delete(letter)
      guesses += 1
      puts "Current guess is: #{guess}" if display
    end
    if display
      puts "The word was #{guess} and took #{guesses} guesses, with #{incorrect} incorrect"
    end
    guesses
  end

  # @param [Object] display If true, will put working strings to the console
  # @return [Hash{null->null}]  A hash of every word with how many guesses it took
  def full_search_complex(display = false)
    output = {}
    words =  @master_words.clone

    i = 0
    words.each do |hangman|
      i += 1
      puts "#{i} - #{hangman}" if (i % 10).zero?
      output[hangman] = guess_complex(hangman, display)
    end

    if display
      output.each do |k, v|
        puts k if v == 26
      end
    end
    output
  end

  def full_search_efficient (display = false)
    output = {}
    words =  full_search_simple(display).select { |k, v| v >= 24 }.keys.dup

    puts words.size

    i = 0
    words.each do |hangman|
      i += 1
      puts "#{i} - #{hangman}" if (i % 10).zero?
      output[hangman] = guess_complex(hangman, display)
    end

    if display
      output.each do |k, v|
        puts k if v == 26
      end
    end
    output
  end

  # @param [Object] hangman the word that needs guessing
  # @param [Object] display if true the method will print it's working to the console
  # @return [Integer] The amount of guesses taken to guess the word
  def guess_complex(hangman, display = false)
    letters = @master_letters.clone
    words = @master_words.clone
    # Remove every word from list that is a different length to hangman
    words.select! { |word| word.length == hangman.length }

    # reindex letters to reflect new word list
    letters.update(letters) do |key|
      value = 0
      words.each do |word|
        value += 1 if word.include? key.to_s
      end
      value
    end

    temp = hangman.clone freeze: false
    guess = ''
    temp.split('').each do
      guess += '_'
    end

    guesses = 0
    incorrect = 0
    while guess != hangman

      letter = letters.key(letters.values.max)
      puts "Guessing #{letter}" if display

      if temp.include? letter.to_s
        puts 'Correct!' if display
        while temp.include? letter.to_s
          i = temp.index(letter.to_s)
          temp[i] = '.'
          guess[i] = letter.to_s
        end
        words.select! { |word| compare(word, guess) }
      else
        puts "Incorrect: #{11 - incorrect} lives remaining" if display
        incorrect += 1
        words.reject! { |word| word.include?(letter.to_s) }
      end

      letters.update(letters) do |key|
        value = 0
        words.each do |word|
          value += 1 if word.include? key.to_s
        end
        value
      end

      letters.delete(letter)
      guesses += 1
      puts "Current guess is: #{guess}" if display
    end
    if display
      puts "The word was #{guess} and took #{guesses} guesses, #{incorrect} incorrect"
    end
    guesses
  end

  # @param [Object] length the length of the word that needs guessing
  # @return [String] A string containing the word to be guessed
  def play(length)
    words = @master_words.clone
    letters = @master_letters.clone

    # Remove every word from list that is a different length to hangman
    words.select! { |word| word.length == length }

    # reindex letters to reflect new word list
    letters.update(letters) do |key|
      value = 0
      words.each do |word|
        value += 1 if word.include? key.to_s
      end
      value
    end

    guess = ''
    length.times do
      guess += '_'
    end

    puts guess
    correct = false

    until correct
      letter = letters.key(letters.values.max)
      puts "You should guess #{letter}"
      puts 'Type Y if it was correct, or N if not'

      contained = gets.chomp
      if contained == 'Y'
        puts 'Enter the locations of letter (1-indexed), then press enter on an empty line'
        array = []
        input = ' '
        while input != ''
          input = gets.chomp
          array.push input
        end
        array.delete_at(array.count - 1)

        array.each do |index|
          guess[index.to_i - 1] = letter.to_s
        end
        words.select! do |word|
          word.include?(letter.to_s) &&
            compare(word, guess)
        end
      else
        words.reject! { |word| word.include?(letter.to_s) }
      end

      letters.update(letters) do |key|
        value = 0
        words.each do |word|
          value += 1 if word.include? key.to_s
        end
        value
      end

      if !guess.include? '_'
        correct = true
      else
        letters.delete(letter)
        puts "Current guess is: #{guess}\n\n"
      end
    end
    puts "Hurrah! The word was #{guess}"
    guess
  end

  # compares a word and an underscored guess to see if word fits
  # @param [Object] word the word that needs to be compared
  # @param [Object] guess the pattern to compare it to
  # @return [TrueClass] A boolean representing if the pattern fits
  def compare(word, guess)
    (0..word.split('').count).each do |i|
      return false if guess[i] != '_' && word[i] != guess[i]
    end
    true
  end
end

time = Benchmark.measure do
  hangman = Hangman.new "words.txt"
  arr = hangman.full_search_complex(false).values.to_a
  puts "Average Guesses: #{arr.inject { |sum, el| sum + el }.to_f / arr.size}"
  # puts(hangman.full_search_efficient(false).select { |_k, v| v > 16})
  # puts(output)
end
puts "Total Time: #{time.real}"
puts "Average Time: #{time.real / 65_000}"