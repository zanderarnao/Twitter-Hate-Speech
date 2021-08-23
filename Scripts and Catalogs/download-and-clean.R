# load necessary libraries

library(tidyverse)
library(rvest)
library(RColorBrewer)
library(tidytext)
library(knitr)
library(downloader)
library(here)
library(topicmodels)
library(textrecipes)


# download hate speech data from GitHub

url <- "https://raw.githubusercontent.com/t-davidson/hate-speech-and-offensive-language/master/data/labeled_data.csv"

download(url = url, destfile = ("labeled_data.csv"), quiet = TRUE) 

### LOAD DATA

# clean and save as .csv
hs_data <- read_csv(here("labeled_data.csv")) %>% 
  mutate(consensus = if_else(
    (count == hate_speech | count == offensive_language | count == neither), 
    TRUE, 
    FALSE)) %>% 
  select(class, tweet, consensus) 

# defining code to convert class column to category names
class_clean <- hs_data$class %>% 
  str_replace("0", "hate speech") %>% 
  str_replace("1", "offensive language") %>% 
  str_replace("2", "neither")

hs_data_clean <- hs_data %>%
  mutate(class = class_clean) 

### EXPLORATORY ANALYSIS

# example posts



# show count of consensus and disagreement

hs_data %>% 
  count(consensus) %>% 
  mutate(prop = n / sum(n),
         percent = prop * 100) %>% 
  kable(format = "simple",
        col.names = c("Consensus", "Count", "Proportion", "Percent"))

# show proportion of each category of content

hs_data_clean %>% 
  count(class) %>% 
  mutate(prop = n / sum(n), 
         percent = prop * 100) %>% 
  kable(format = "simple",
        col.names = c("Content Type", "Count", "Proportion", "Percent"))

# show proportion of consensus posts by category 

hs_data_clean %>% 
  group_by(class) %>% 
  count(consensus) %>% 
  mutate(prop = n / sum(n), 
         percent = prop * 100) %>% 
  kable(format = "simple",
        col.names = c("Content Type", "Consensus", "Count", "Proportion", "Percent"))

hs_data_clean %>% 
  ggplot(aes(x = class, fill = consensus)) +
  geom_bar(position = "fill")

