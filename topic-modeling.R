# load necessary libraries

library(tidyverse)
library(rvest)
library(RColorBrewer)
library(tidytext)
library(knitr)
library(downloader)
library(here)
library(topicmodels)
library(tictoc)
library(furrr)
library(textrecipes)


# run tidy and import 

source(here("down-and-clean.R"))

  # separate hate speech and offensive language into two data frames

  hs_tweets <- hs_data_clean %>% 
  filter(class == "hate speech") %>% 
    select(tweet)
  
  
# define a function to create and apply an LDA to our data then reformat for fitting
  
create_and_apply_rec <- function(df) {
  
  LDA_rec <- recipe(~ tweet, data = df) %>%
    step_sample(size = 1e04) %>%
    step_tokenize(tweet) %>% 
    step_stopwords(tweet) %>% 
    step_ngram(tweet, num_tokens = 4, min_num_tokens = 1) %>%   
    step_tokenfilter(tweet, max_tokens = 2500) %>% 
    step_tf(tweet)
  
  transformed_df <- prep(LDA_rec) %>% 
    bake(new_data = NULL) %>% 
    mutate(id = row_number())
  
  final_dtm <- transformed_df %>%
    pivot_longer(
      cols = -c(id),
      names_to = "token",
      values_to = "n"
    ) %>%
    filter(n != 0) %>% 
    mutate(
      token = str_remove(string = token, pattern = "tf_tweet_")
    ) %>% 
    cast_dtm(id, token, n) # convert back into document-term matrix format 
  
  return(final_dtm)
  
}

hs_dtm <- create_and_apply_rec(hs_tweets)

# fit our document-term matrices two example LDA models 

# hs_lda4 <- LDA(hs_dtm, k = 4, control = list(seed = 123))

# hs_lda12 <- LDA(hs_dtm, k = 12, control = list(seed = 123))

# hs_lda20 <- LDA(hs_dtm, k = 20, control = list(seed = 123))

# define a function to iterate through and visualize the perplexity score of various k values

n_k <- c(4, 20, 50, 100)

create_models <- function(folder, save_file_name, n_topics, lda_dtm) {
    plan(multisession)
    
    lda_compare <- n_topics %>%
      future_map(LDA, x = lda_dtm, control = list(seed = 123))
    
    save(lda_compare, 
      file = here("models", folder, save_file_name))
    
    return(lda_compare)
  }

hs_lda_compare <- create_models("hate speech", "hs_lda_compare.Rdata", n_k, hs_dtm)

# define a function to visualize the perplexity scores of LDA models with various values of k 

visualize_perplexity <- function(n_topics, models) {
 
  tibble(
    k = n_topics,
    perplex = map_dbl(models, perplexity)
  ) %>%
      ggplot(aes(x = k, y = perplex)) +
      geom_point() +
      geom_line() +
      labs(
        title = "Perplexity of Various LDA Topic Models for Hate Speech",
        subtitle = "Finding the optimal number of topic",
        x = "Number of topics",
        y = "Perplexity Score"
      )
}

visualize_perplexity(n_k, hs_lda_compare)

# define a function to visualize most common words associated with the first few major topics

visualize_top_terms <- function(lda_compare, best_model, n_1, n_2) {

lda_td <- tidy(lda_compare[[best_model]])

top_terms <- lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  filter(topic >= n_1 & topic =< n_2) %>%
  mutate(
    topic = factor(topic),
    term = reorder_within(term, beta, topic)
  ) %>%
  ggplot(aes(term, beta, fill = topic)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~topic, scales = "free", ncol = 3) +
  coord_flip()

}

visualize_top_terms(hs_lda_compare, 4, 1, 10)

visualize_top_terms(hs_lda_compare, 4, 11, 20)

visualize_top_terms(hs_lda_compare, 4, 21, 30)

visualize_top_terms(hs_lda_compare, 4, 31, 40)

# further explore LDV topics interactively 

