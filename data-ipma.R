library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

# Load warnings and district data
warnings_url <- "https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json"
districts_url <- "https://api.ipma.pt/open-data/distrits-islands.json"

warnings <- fromJSON(warnings_url)
districts <- fromJSON(districts_url)$data

# Define districts of interest
locais_interesse <- c("Aveiro", "Beja", "Braga", "Bragança", "Castelo Branco", 
                      "Coimbra", "Évora", "Faro", "Guarda", "Leiria", 
                      "Lisboa", "Portalegre", "Porto", "Santarém", "Setúbal", 
                      "Viana do Castelo", "Vila Real", "Viseu")

# Filter districts to only those of interest
districts_filtered <- districts %>%
  filter(local %in% locais_interesse)

# Join data on idAreaAviso
merged_data <- districts_filtered %>%
  left_join(warnings, by = "idAreaAviso")

# Translate awareness levels
merged_data <- merged_data %>%
  mutate(awarenessLevelID = case_when(
    awarenessLevelID == "green" ~ "Verde",
    awarenessLevelID == "yellow" ~ "Amarelo",
    awarenessLevelID == "orange" ~ "Laranja",
    awarenessLevelID == "red" ~ "Vermelho",
    awarenessLevelID == "grey" ~ "Cinzento",
    TRUE ~ "Sem Aviso"  # Assign "Sem Aviso" for unexpected or missing values
  ))

# Reshape data to the desired structure, filling empty cells with "Sem Aviso"
reshaped_data <- merged_data %>%
  select(local, awarenessTypeName, awarenessLevelID) %>%
  pivot_wider(
    names_from = awarenessTypeName,
    values_from = awarenessLevelID,
    values_fill = list(awarenessLevelID = "Sem Aviso")
  )

# Write to CSV
write_csv(reshaped_data, "IPMA_alertas.csv")
