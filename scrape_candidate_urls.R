
library(tidyverse)
library(rvest)

election_areas_page <- "https://www.dr.dk/nyheder/politik/folketingsvalg/din-stemmeseddel"

# scrape election area urls 
election_areas_urls <- read_html(election_areas_page)

election_areas_url_list <- election_areas_urls %>%
  html_elements(".AccordionGrid_link__cGkec") %>%
  html_attr("href") %>%
  paste0("https://www.dr.dk", .)

# scrape candidate urls 
all_candidate_urls <- c()

for (url in election_area_url_list) {
  candidate_urls <- url %>%
  read_html() %>%
  html_elements(".AccordionGrid_link__cGkec") %>%
  html_attr("href") %>%
  paste0("https://www.dr.dk", .)
  
  all_candidate_urls <- all_candidate_urls %>% append(candidate_urls)
}

all_candidate_urls <- unique(all_candidate_urls)

write_rds(all_candidate_urls, "data/all_candidate_urls.rds")
#length(all_candidate_urls)


