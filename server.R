###############################################
# Coursera Data Science JHU Capstone Project  #
# Text Prediction App -Swiftlet               #
# Konstantina Kyriakouli                      #
###############################################




shinyServer(function(input,output){
  
  observeEvent(input$gobutton,{
  user_input<-as.character(isolate(input$sentence))
  withProgress(message = 'Loading:', value = 0, {
    incProgress(1/2, detail = "Pre-processing")
    input<-preProcess(user_input)
    n<-length(input)
    incProgress(1, detail = "Searching n-gram models")
  
    if(n>=2){
    
        words<-paste(input[n-1], input[n], sep=" ")
        pred_results<-find_trigram(words)
    
      } else if(n==1) {
    
        words<-input
        pred_results<-find_bigram(words)
    
      }  else if(n==0){
    
        pred_results<-find_unigram()
      
      }
    incProgress(2, detail = "Done!")
  
  
  })
  output$top<-renderText({pred_results$next_word[1]})
  output$predictions<-renderDataTable({pred_results[1:100,]})
  })
})



  




