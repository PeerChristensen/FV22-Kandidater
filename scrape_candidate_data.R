library(tidyverse)
library(rvest)
library(RSelenium)
rD <- rsDriver(browser="firefox", port=4544L, verbose=F)
remDr <- rD[["client"]]

candidate_urls <- read_rds("data/all_candidate_urls.rds")

candidates_df <- NULL

counter = 1
for (url in candidate_urls[909:length(candidate_urls)]){
  
  skip_to_next <- FALSE
  print(counter)
  counter = counter + 1
  
  remDr$navigate(url)
  tryCatch(
    expr = {

  remDr$findElements("class name", "dre-button")[[1]]$clickElement()

  html <- remDr$getPageSource()[[1]] %>% read_html()
    
  data <- html %>%
    html_element(".CandidateBaseInfo_candidateInfo__9ZYqw") %>%
    html_children() %>%
    html_text() %>%
    as_tibble() %>%
    mutate(name = c("navn", "parti", "kreds")) 
    
  answers <- html %>%
    html_elements(".Answer_candidateFirstName__XTbqP") %>%
    html_attr("aria-label") %>%
    str_split(pattern = 'svaret: ', simplify = TRUE) %>%
    .[,2] %>%
    str_extract(pattern = ".*nig") %>% 
    tibble() %>% rename(value = ".") %>% 
    mutate(name = paste0("Q",row_number()))
  
    },
  error = function(e) { skip_to_next <<- TRUE}
  )
  if(skip_to_next) { next } 
  
  if (nrow(answers) == 25) {
    
    combined_data <- rbind(data, answers) %>% 
      pivot_wider()
    candidates_df <- rbind(candidates_df, combined_data)
  }
    
  Sys.sleep(3)
}

write_csv(candidates_df,"data/candidates_data.csv")

candidates_df <- candidates_df %>%
  pivot_longer(cols = starts_with("Q")) %>%
  mutate(value = case_when(value == "Uenig" ~ -2,
                           value == "Lidt uenig" ~ -1,
                           value == "Lidt enig" ~ 1,
                           value == "Enig" ~ 2
                           )) %>%
  pivot_wider(names_from=name, values_from = value)
   
write_csv(candidates_df,"data/candidates_data_numeric.csv")


