
#Clearing global environment and loading necessary packages
rm(list = ls())
setwd("") #The full path to the folder with this script and the data should be specified between quotation brackets
library(pdftools)
library(tidytext)
library(tidyverse)
library(data.table)
library(fs)
library(crayon)

  
# Configuration
keywords_1 <- c("observational", "non-interventional", "RWD", "RWE", "registry", "registries", "record", "records", "medical charts", "medical chart", "literature")
keywords_2 <- c("Real-world", "Real world", "retrospective", "historical control", "external comparator", "single arm", "single-arm", "external control", "external arm")

#For ease of use, we aggregate both rounds of keyword scans into a single list

keywords <- c(keywords_1, keywords_2)

# Regex Patterns
header_pattern <- "^\\d+\\.\\d+\\.?\\d*\\.\\s+[A-Z].*"

# File Discovery
pdf_paths <- as.character(dir_ls(path = "PDF", recurse = TRUE, glob = "*.pdf"))

# Processing Loop
results_list <- list()

for (i in seq_along(pdf_paths)) {
  
  current_path <- pdf_paths[i]
  cat("Scanning (", i, "/", length(pdf_paths), "): ", basename(current_path), "...\n", sep="")
  
  # Read PDF
  all_pages <- tryCatch(pdf_text(current_path), error = function(e) return(NULL))
  
  if (is.null(all_pages) || length(all_pages) < 6) {
    message(" -> Skipped: Unreadable or fewer than 6 pages.")
    next
  }
  
  # Process text: Skip table of contents (first 5 pages), collapse, and split into lines
  body_text <- all_pages[6:length(all_pages)] %>% 
    paste(collapse = "\n") %>% 
    readr::read_lines()
  
  # Identify headers
  header_indices <- which(str_detect(body_text, header_pattern))
  
  if (length(header_indices) > 0) {
    for (j in seq_along(header_indices)) {
      
      # Determine section boundaries
      start_line <- header_indices[j]
      end_line   <- if (j < length(header_indices)) header_indices[j+1] - 1 else length(body_text)
      
      # Clean section text for searching
      section_raw <- body_text[start_line:end_line] %>% paste(collapse = " ")
      section_clean <- str_to_lower(str_squish(section_raw))
      
      # Count individual keywords
      # This creates a 1-row data frame with a column for each keyword
      keyword_counts <- map_dfc(keywords, function(kw) {
        # \\b ensures whole-word matching
        count <- str_count(section_clean, paste0("\\b", str_to_lower(kw), "\\b"))
        return(setNames(as.data.frame(count), kw))
      })
      
      # Create metadata for this section
      meta_data <- data.frame(
        File = basename(current_path),
        Section = str_squish(body_text[start_line]),
        stringsAsFactors = FALSE
      )
      
      # Combine metadata with the keyword columns and store in list
      results_list[[length(results_list) + 1]] <- cbind(meta_data, keyword_counts)
    }
  }
}

# Finalize Results
if (length(results_list) > 0) {
  final_results <- bind_rows(results_list)
  
  # Replace NA counts with 0
  final_results[is.na(final_results)] <- 0
  
  cols_to_check <- keywords
  final_results_cleaned <- final_results %>%
    filter(!if_all(all_of(cols_to_check), ~ .x == 0))
  
  #print(head(final_results))
  
  write.csv(final_results_cleaned, file = "OUTPUT/KeywordScanResults.csv", row.names = FALSE)
  message(bold(green("Results exported successfully. Note: only rows with hits are included in export. For the full overview, open final_results from the global environment. Alternatively, remove the hashtag at line 104 and source the script again.")))

} else {
  message(bold(red("No sections found matching the header pattern.")))
}



#write.csv(final_results, file = "OUTPUT/KeywordScanResults_ALL.csv", row.names = FALSE)