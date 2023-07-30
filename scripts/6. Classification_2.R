############################################################
#         Problem Set 3. Predicting Poverty
#           Big data and Machine Learning
#             Universidad de los Andes
##########################################################

#Authors:

#- Lucia Fillippo
#- Miguel Angel Victoria Simbaqueva 
#- Irina Andrea Vélez López  
#- Daniel Casas Bautista  

# Initial configuration ---------------------------------------------------

rm(list = ls())

path_sript <- rstudioapi::getActiveDocumentContext()$path
path_folder <- dirname(path_sript)
setwd(path_folder)

# Libraries
require(pacman)
library(tidyverse)
p_load(tidyverse,
       rio,
       sf,
       rstudioapi,
       stargazer,
       glmnet,
       MLmetrics,
       caret,
       dplyr)

# Importing from Github
i_test_hogares <- readRDS("../stores/i_test_hogares.rds")
i_train_hogares <- readRDS("../stores/i_train_hogares.rds")
predict_en <- readRDS("../stores/predict_en.rds")

##MÉTODO 1 - NO SIRVE PORQUE SALEN VALORES NAs en la base de datos Predict_en

# Crear la variable dummy de pobreza en la base de datos predict_en
predict_en <- predict_en %>%
  left_join(select(p_train_hogares, id, Lp), by = "id") %>%
  mutate(dummy_pobreza = ifelse(tot_income_h < Lp, 1, 0)) %>%
  select(-Lp)  # Eliminar la columna Lp para evitar duplicados


# Paso 1: Unir la base de entrenamiento con la base de ingresos predichos (predict_en) usando la llave 'id'
p_train_hogares <- p_train_hogares %>%
  left_join(select(predict_en, id, dummy_pobreza), by = "id")

# Paso 2: Unir la base de test con la base de ingresos predichos (predict_en) usando la llave 'id'
test_hogares <- test_hogares %>%
  left_join(select(predict_en, id, dummy_pobreza), by = "id")

##MÉTODO 2
# Paso 1: Unir la base de entrenamiento con la base de ingresos predichos (predict_en) usando la llave 'id'
p_train_hogares <- p_train_hogares %>%
  left_join(select(predict_en, id, tot_income_h, Lp), by = "id") %>%
  mutate(dummy_pobreza = ifelse(tot_income_h < Lp, 1, 0)) %>%
  select(-tot_income_h, -Lp)  # Eliminar columnas innecesarias

# Paso 2: Unir la base de test con la base de ingresos predichos (predict_en) usando la llave 'id'
test_hogares <- test_hogares %>%
  left_join(select(predict_en, id, tot_income_h, Lp), by = "id") %>%
  mutate(dummy_pobreza = ifelse(tot_income_h < Lp, 1, 0)) %>%
