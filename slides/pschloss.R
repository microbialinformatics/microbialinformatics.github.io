readPaper <- function(file){
	words <- scan(file, what="")
	words <- gsub("\\W", "", words)
	words <- tolower(words)
	return(list(words))
}

wordCount <- function(word, wordList){
	word <- tolower(word)
	word.count <- numeric()	
	for(w in word){
		word.count[w] <- sum(wordList[[1]]==w)
	}
	names(word.count) <- NULL
	return(word.count)
}
