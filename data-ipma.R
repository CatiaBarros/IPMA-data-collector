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

# Verifique se 'districts' está no formato correto
if (!is.data.frame(districts)) {
  districts <- as.data.frame(districts)
}

# Remova linhas com 'local' inválido
districts <- districts %>%
  filter(!is.na(local) & local != "")

# Defina os distritos de interesse
locais_interesse <- c("Aveiro", "Beja", "Braga", "Bragança", "Castelo Branco", 
                      "Coimbra", "Évora", "Faro", "Guarda", "Leiria", 
                      "Lisboa", "Portalegre", "Porto", "Santarém", "Setúbal", 
                      "Viana do Castelo", "Vila Real", "Viseu")

# Filtre os distritos de interesse
districts_filtered <- districts %>%
  filter(local %in% locais_interesse)

# Verifique se o filtro resultou em dados
if (nrow(districts_filtered) == 0) {
  stop("Nenhum distrito correspondente foi encontrado!")
}

# Junte os dados com os avisos
merged_data <- districts_filtered %>%
  left_join(warnings, by = "idAreaAviso")

# Traduza os níveis de alerta
merged_data <- merged_data %>%
  mutate(awarenessLevelID = case_when(
    awarenessLevelID == "green" ~ "Verde",
    awarenessLevelID == "yellow" ~ "Amarelo",
    awarenessLevelID == "orange" ~ "Laranja",
    awarenessLevelID == "red" ~ "Vermelho",
    awarenessLevelID == "grey" ~ "Cinzento",
    TRUE ~ "Sem Aviso"
  ))

# Transforme os dados na estrutura desejada
reshaped_data <- merged_data %>%
  select(local, awarenessTypeName, awarenessLevelID) %>%
  pivot_wider(
    names_from = awarenessTypeName,
    values_from = awarenessLevelID,
    values_fill = list(awarenessLevelID = "Sem Aviso")
  )

# Escreva para CSV
write_csv(reshaped_data, "IPMA_alertas.csv")
