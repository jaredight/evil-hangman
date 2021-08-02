
clear all
set more off

global directory "C:\Users\jaredmw2.BYU\Documents\hangman"
cd "$directory"
import delimited "words_alpha.csv"
rename v1 words

display "Enter word length: " _request(wlength)
display "$wlength"
keep if length(words)==$wlength

display "Enter number of attempts: " _request(num_tries)
display "$num_tries"
local used_letters = ""

local answer = ""
di "$wlength"
forvalues j = 1/$wlength {
    local l`j' = "-"
	local answer `answer'`l`j''
}
di "`answer'"
capture drop answer
gen answer = "`answer'"
di "`answer'"

forvalues i = 1/$num_tries {
    while strpos("`answer'", "-") { //check if user has found an answer
    di $num_tries - `i' + 1 " tries remaining"
	display "letters used so far: " _newline "`used_letters'"
	display "Guess a letter: " _request(letter)
	display "you guessed $letter"
	local used_letters `used_letters' $letter
	forvalues j = 1/$wlength {
	    gen v`j' = 0
		replace v`j' = 1 if "$letter" == substr(words, `j', 1)
		egen t`j' = total(v`j')
	}
	
	* find most common group
	gen code = ""
	tostring v*, replace
	forvalues j = 1/$wlength {
	    replace code = code + v`j'
	}
	encode code, gen(index)
	egen keep_index = mode(index), minmode
	keep if index==keep_index
	local code = code
	di "`code'"	

	* create word
	forvalues j = 1/$wlength {
	    if strpos(v`j', "1") {
		    di "`j'--->>"
			replace answer = substr(answer, 1, `j'-1) + "$letter" + substr(answer, `j' + 1, .)
		}
	}
	local answer = answer
	di "`answer'"
	keep words answer
	}
}

if !strpos("`answer'", "-") {
	di "you won!!!"
}



