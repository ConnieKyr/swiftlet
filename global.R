###############################################
# Coursera Data Science JHU Capstone Project  #
# Text Prediction App -Swiftlet               #
# Konstantina Kyriakouli                      #
###############################################



library(shiny)
library(stringr)
library(stringi)
library(dplyr) 
library(lplyr) 
library(tm)



# Loading the pre-computed n-gram models
unigram<-readRDS("unigram.rds")
bigram<-readRDS("bigram.rds")
trigram<-readRDS("trigram.rds")
bigram_leftover<-readRDS("bleftover.rds")
trigram_leftover<-readRDS("tleftover.rds")


# Function for preprocessing user input
preProcess<-function(sentence){
  
  sentence<-tolower(sentence)
  words<-unlist(stri_extract_all_words(sentence))
  words<-removePunctuation(words)
  words<-removeNumbers(words)
  nonEnglishChars<-"[^A-Za-z'-[:space:]]"
  words<-stri_replace_all(words, replacement="", regex=nonEnglishChars)
  nonwords<-(words=="")|(words=="'")
  words<-words[!nonwords]
  return(words)
  
} 

# n-gram search functions
# searching the trigram table for the 2 last input words, and backoff to the bigram and unigram ones
find_trigram<-function(words){
  
  rows_found<-nrow(trigram[(trigram$first_word==words),])
  if(rows_found!=0) { 
    
    bigrams_found<-trigram[(trigram$first_word==words),]
    results<-bigrams_found %>% ungroup() %>% select(next_word, prob)
    
    # if the 3-gram table doesn't give us at least one helpful -reliable (high frequency (>5) trigram)- prediction, we look lower :
    if(!(sum(bigrams_found$discount)>(0.781*rows_found))) {
      
      beta<-trigram_leftover[(trigram_leftover$first_word==words),]$leftover
      words<-word(words,-1)
      rows_found<-nrow(bigram[(bigram$first_word==words),])
      if(rows_found!=0) {
        
        
        unigrams_found<-bigram[(bigram$first_word==words) && !(bigram$next_word %in% results$next_word),]
        unigrams_found<-unigrams_found %>% mutate(prob=prob*(beta/sum(unigrams_found$prob)))
        results<-rbind(results, (unigrams_found %>% ungroup() %>% select(next_word, prob)))
        
        
      }
      
      else {
        
        # backoff in unigrams table
        words_found<-head(unigram[!(unigram$next_word %in% results$next_word),], 5)
        words_found<-words_found %>% mutate(prob=prob*(beta/sum(words_found$prob)))
        results<-rbind(results, (words_found %>% ungroup() %>% select(next_word, prob)))
        
      }
      
      
    } 
    
    return(results)
    
  } else {  
    
    results<-find_bigram(word(words,-1))
    return(results)
    
  }
  
  
}




# searching the bigram table for the last input word, and backoff to the unigram one
find_bigram<-function(words){
  
  rows_found<-nrow(bigram[(bigram$first_word==words),])
  if(rows_found!=0) {
    
    
    unigrams_found<-bigram[(bigram$first_word==words) ,]
    results<-unigrams_found %>% ungroup() %>% select(next_word, prob)
    
    # backoff to lower order to get more results if needed:
    if(!(sum(unigrams_found$discount)>(0.781*rows_found))) {
      
      beta<-bigram_leftover[(bigram_leftover$first_word==words),]$leftover  
      words_found<-head(unigram[!(unigram$next_word %in% results$next_word),], 5)
      words_found<-words_found %>% mutate(prob=prob*(beta/sum(words_found$prob)))
      results<-rbind(results, (words_found %>% ungroup() %>% select(next_word, prob)))
    } 
    
    return(results)  
  }
  
  else {  
    results<-find_unigram()
    return(results)
  }
}

# searching the unigram table for the most frequent words
find_unigram<-function(){
  
  words_found<-head(unigram, 5)
  results<-words_found %>% ungroup() %>% select(next_word, prob)
  return(results)
  
  
}
