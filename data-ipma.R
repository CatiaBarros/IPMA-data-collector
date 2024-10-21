library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

warnings_url <- "https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json"
districts_url <- "https://api.ipma.pt/open-data/distrits-islands.json"

warnings <- fromJSON(warnings_url)
districts <- fromJSON(districts_url)$data

locais_interesse <- c("Aveiro", "Beja", "Braga", "Bragança", "Castelo Branco", 
                      "Coimbra", "Évora", "Faro", "Guarda", "Leiria", 
                      "Lisboa", "Portalegre", "Porto", "Santarém", "Setúbal", 
                      "Viana do Castelo", "Vila Real", "Viseu")

districts_filtered <- districts %>%
  filter(local %in% locais_interesse)

merged_data <- districts_filtered %>%
  left_join(warnings, by = c("idAreaAviso" = "idAreaAviso"))

merged_data <- merged_data %>%
  mutate(awarenessLevelID = case_when(
    awarenessLevelID == "green" ~ "Verde",
    awarenessLevelID == "yellow" ~ "Amarelo",
    awarenessLevelID == "orange" ~ "Laranja",
    awarenessLevelID == "red" ~ "Vermelho",
    awarenessLevelID == "grey" ~ "Cinzento",
    TRUE ~ awarenessLevelID  # Caso algum valor não seja esperado
  ))


reshaped_data <- merged_data %>%
  select(local, awarenessTypeName, awarenessLevelID) %>%
  pivot_wider(names_from = awarenessTypeName, values_from = awarenessLevelID)

write_csv(reshaped_data, "IPMA_alertas.csv")
