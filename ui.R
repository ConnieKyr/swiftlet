###############################################
# Coursera Data Science JHU Capstone Project  #
# Swiftlet: Text Prediction App               #
# Konstantina Kyriakouli                      #
###############################################

library(shiny)
library(shinythemes)
library(markdown)


fluidPage(theme=shinytheme("superhero"),
  
  #Application title
  titlePanel("Swiftlet: Your new text prediction App"),
  
  #h4("For complete instructions on how to use the app and some useful documentation, check out the \"App documentation\" tab first."), 
  #Sidebar  
  
  sidebarPanel(
      
      h3("Please enter your unfinished sentence to get a prediction for the next word and click the Submit button"),
      textInput(inputId = "sentence", 
                label = "", 
                value = ""), 
      #submitButton(text="Apply Changes", icon=NULL, width=NULL)
      actionButton("gobutton", "Submit", icon("paper-plane"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
      
       ),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel(
          title="Results",
          h4("The next word in your sentence could be:", textOutput("top")),
          div(dataTableOutput("predictions"), style='font-size:150%')        
        ),
        
        tabPanel(
          title="App documentation",
          includeMarkdown("swiftlet_doc.Rmd")  
          )
      
      
      
    )
    )
  
)
