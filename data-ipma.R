library(jsonlite)
library(dplyr)
library(tidyr)

# URL do JSON
url <- "https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json"

# Carregar JSON
data <- fromJSON(url)

# Tabela de mapeamento para awarenessLevelID
awareness_map <- c(
  "green" = "Verde",
  "yellow" = "Amarelo",
  "orange" = "Laranja",
  "red" = "Vermelho",
  "grey" = "Cinzento"
)

# Tabela de mapeamento para idAreaAviso
area_map <- c(
  "BGC" = "Bragança",
  "ACE" = NA,  # Excluir
  "VIS" = "Viseu",
  "EVR" = "Évora",
  "PTO" = "Porto",
  "AOC" = NA,  # Excluir
  "GDA" = "Guarda",
  "FAR" = "Faro",
  "VRL" = "Vila Real",
  "STB" = "Setúbal",
  "STM" = "Santarém",
  "MRM" = NA,  # Excluir
  "VCT" = "Viana do Castelo",
  "LRA" = "Leiria",
  "MCN" = NA,  # Excluir
  "BJA" = "Beja",
  "CBO" = "Castelo Branco",
  "AVR" = "Aveiro",
  "CBR" = "Coimbra",
  "PTG" = "Portalegre",
  "MPS" = NA,  # Excluir
  "BRG" = "Braga",
  "MCS" = NA   # Excluir
)

# Substituir os valores de awarenessLevelID e idAreaAviso
data <- data %>%
  mutate(
    awarenessLevelID = awareness_map[awarenessLevelID],
    idAreaAviso = area_map[idAreaAviso]
  ) %>%
  filter(!is.na(idAreaAviso))  # Excluir os NA (áreas excluídas)

# Pivotar para criar o formato do CSV final
final_data <- data %>%
  select(idAreaAviso, awarenessTypeName, awarenessLevelID) %>%
  pivot_wider(names_from = awarenessTypeName, values_from = awarenessLevelID) %>%
  rename(local = idAreaAviso)

# Preencher os NAs com "Verde" (caso alguma categoria esteja ausente)
final_data[is.na(final_data)] <- "Cinzento"

# Salvar o CSV
write.csv(final_data, "avisos_ipma.csv", row.names = FALSE)

# Mensagem de sucesso
cat("CSV gerado com sucesso como 'avisos_ipma.csv'\n")
