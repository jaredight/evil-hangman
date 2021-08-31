
program define hangman
	
	global directory "C:\Users\jaredmw2.BYU\Documents\hangman"

	* import dataset of words
	quietly {
	preserve
	cd "$directory"
	import delimited "words_alpha.csv", clear
	rename v1 words
	}

	* get word length from user input
	while 1 {
		display "Enter word length: " _request(wlength)
		capture confirm integer number $wlength
		if _rc {
			di "Word length must be an integer"
			continue
		}
		else if $wlength < 1 | $wlength > 26 {
			di "Word length must be between 1 and 26"
		}
		else {
			continue, break
		}
	}
	quietly keep if length(words)==$wlength

	* get number of attempts from user input
	while 1 {
		display "Enter number of attempts: " _request(num_tries)
		capture confirm integer number $num_tries
		if _rc {
			di "Number of attempts must be an integer"
			continue
		}
		else if $num_tries < 1 | $num_tries > 26 {
			di "Number of attempts must be between 1 and 26"
		}
		else {
			continue, break
		}
	}

	* create word to be populated as user plays
	forvalues j = 1/$wlength {
		local answer "`answer'" + "_"
	}
	gen answer = "`answer'"

	* let user guess letters
	local used_letters = ""
	forvalues i = 1/$num_tries {

		* get letter from user input
		di $num_tries - `i' + 1 " tries remaining"
		while 1 {
			di "Guess a letter: " _request(letter)
			global letter = lower("$letter")
			if strlen("$letter") != 1 {
				di "Enter a single letter"
			}
			else if !regexm("$letter", "^[a-z]$") {
				di "Enter an alphabetic character"
			}
			else if strpos("`used_letters'", "$letter") {
				di "You've already used that letter. Choose a letter you haven't used yet"
				di "Letters used so far: `used_letters'"
			}
			else {
				continue, break
			}
		}
		sleep 1000
		
		* do the data thing
		quietly {
		* find most common group
		local used_letters `used_letters' $letter
		quietly forvalues j = 1/$wlength {
			gen v`j' = 0
			replace v`j' = 1 if "$letter" == substr(words, `j', 1)
			egen t`j' = total(v`j')
		}
		gen code = ""
		tostring v*, replace
		forvalues j = 1/$wlength {
			replace code = code + v`j'
		}
		encode code, gen(index)
		egen keep_index = mode(index), minmode
		keep if index==keep_index
		local code = code
		* create word
		forvalues j = 1/$wlength {
			if strpos(v`j', "1") {
				replace answer = substr(answer, 1, `j'-1) + "$letter" + substr(answer, `j' + 1, .)
			}
		}
		local answer = answer
		keep words answer
		}
		
		* tell user if their guess was successful
		if !strpos("`answer'", "_") { //break out of loop if no more letters are missing
			continue, break
		}
		if strpos("`code'", "1") {
			di "You guessed a letter! Word so far: `answer'"
		}
		else {
			di "The word does not contain the letter '${letter}'. Word so far: `answer'" 
		}
	}

	* display final output
	if strpos("`answer'", "_") {
		gen rand = runiform()
		sort rand
		local word = words[1]
		di "You lost :(" _newline "The word was `word'"
	}
	else {
		di "You won!!" _newline "The word was `answer'"
	}
	quietly restore
end 


