#Hangman Solver
##Using the Program
There are a few different ways to use this program depending on your goals, however each version uses one of the same 2 algorithms to guess a hangman word as efficiently as possible.

####initialize(file)
Initialises the hangman solver based off the text file passed in, which should contain a list of words, no special characters and all lowercase, separated by newlines.

It will run through and popularise the letters hash with each letter linked to how many words it appears in.
If no parameter is passed it will use the British English word list included, with around 65k words

####guess_simple(display)
Guesses a word according to the simple algorithm, outlined below, and returns an integer of how many total guesses were needed.
If `display` is set to true, the method will show each letter that is being guessed, as well as whether or not it is correct, along with the current guessed word

####full_search_simple(display)
Performs the `guess_simple(display)` algorithm on every word in the word list, returning a hash of each word and how many guesses were needed

####guess_complex(display)
Guesses a word according to the complex algorithm, outlined below, and returns an integer of how many total guesses were needed.
If `display` is set to true, the method will show each letter that is being guessed, as well as whether or not it is correct, along with the current guessed word

####full_search_complex(display)
Performs the `guess_complex(display)` algorithm on every word in the word list, returning a hash of each word and how many guesses were needed

####full_search_efficient(display)
Performs the full_search_efficient algorithm on the word list, returning a hash of the more difficult words and how many guesses they took

####play(length)
A function designed for helping you succeed at a third party's game of hangman, simply enter the length of the word and it'll walk you through the complex algorithm.
It will recommend the best (most common) remaining letter for you to guess, if it is correct you must enter the (1-indexed) location of every letter, to have it recommend the next best letter

####compare(word, guess)
`guess` must be an underscored pattern representing a working guess, e.g. "_pp_e" and `word` is the word to compare if it fits the pattern.
As a guide, `compare("apple", _pp_e)` returns `true` and `compare("orange:, _pp_e)` returns `false`

####The Simple Algorithm
The simple algorithm checks the word list, makes a hash of letters with how many of the words they appear in, and guesses the letters in order of descending frequency

On average this performs okay, and is very fast to execute, running through my 65k word list in just 2.2 seconds, an average of just 0.00003s per word if the output is turned off and assuming Ruby's benchmarking is accurate.
However it also averages 17 guesses per word, which is very high given that the maximum is 26. I believe this runs in O(N) time

However, as it guesses the words on a simple letter frequency pattern, it is quickly fooled by any word containing a low frequency letter (J, Q, Z, or X) as it will always guess the letters last.

Overall I think it's okay, in most situations it'll help, and would be useful in real life as remembering a letter frequency list is pretty manageable for a human

####The Complex Algorithm
First step, when it is given a word to guess, it removes any words from the word list that are a different length, as these are useless for finding the word.
It then runs through the remaining word list to populate the letter frequency hash with the occurrences in the words.

It then guesses the most common letter from the letter frequency hash. 
If it is correct, fill in all positions the letter appears, then remove all words from the list that don't fit this pattern.
If it is incorrect, remove all words from the list that contain the guessed letter. 
Finally, rerun the letter frequency search with the remaining words.

This dramatically cuts down on the number of incorrect guesses, meaning it can correctly guess the word most of time. 
However this efficiency is counteracted with how much longer each word takes to guess, taking 6162s (~1hr 42min) for the same 65k words, an average of 0.09s per word.
It does take just 9.15 guesses on average, nearly halving the amount of guesses the Simple Algorithm takes.
I believe this algorithm runs in O(N^2) time but honestly Big O is really awkward and I'm bad at it.

I personally think this is less of an issue than it seems. Hangman as a game is not about time efficiency, instead its about guessing efficiency.

####The Efficient Algorithm
A combination of both algorithms, and only useful for a full search of the word list, not for individual guesses. 
It first runs the simple search algorithm to filter the word list, then runs the complex search on any word that took 24 or more guesses.

This is a bad algorithm in a lot of ways, and I am searching for ways to improve it, as the words that take >=24 guesses all contain Q,Z, or J, which means you could easily just filter by those letters.
So as much as it is definitely flawed, and doesn't even return a complete word list, the upside is that it produces most of the difficult words for the complex algorithm in 300s, or an average of 0.004s per word.
This comes with needing just 10.0 guesses on average, a great improvement on the Simple Algorithm
