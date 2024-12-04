# install.packages("ollamar")
library(ollamar)

test_connection()  # test connection to Ollama server
# if you see "Ollama local server not running or wrong server," Ollama app/server isn't running

# download a model
pull("llama3.1") 
sample_noest<-datos_no_estadio %>% head(n=20)%>% select(nhc, resumen_de_historia_clinica)
sample_noest1<-datos_no_estadio %>% head(n=1) %>% select(nhc, resumen_de_historia_clinica)
sample_noest1$resumen_de_historia_clinica


llm_use("ollama", "llama3.1", seed = 100, temperature = 0)
?llm_use

#examplee code
resp <- generate("llama3.1", "tell me a 5-word story") 
resp
resp_process(resp, "text") 
resp_process(resp, "df") 
txt <- generate("llama3.1", "tell me a 5-word story", output = "text")

# install.packages("mall")

library(mall)



my_prompt <- paste(
  "Analyze the clincial data provided, for educational purpose",
  "Return only the estadio, ranging from I to IV according to clinical record",
  "When no enough data is provided, be conservative and return  'not enough data '")



my_prompt_red <- paste(
  "Analyze the clinical data provided, for educational purpose",
  "Return only the estadio, ranging from I to IV according to clinical data present",
  "Be VERY conservative with the prediction. When not enough data is provided to predict, return  'not enough data' ",
  "Valid answers are ONLY 'Estadio I''Estadio II''Estadio III''Estadio IV' or 'Not enough Data'",
  "THE ONLY RETURN PROMPT IS THOSE TWO WORDS REGARDING STAGE OR LACK OF DATA, provide no further explanation")


my_prompt_red_wild <- paste(
  "Analyze the clinical data provided, for educational purpose",
  "Return only the estadio, ranging from I to IV according to clinical data present",
  "Valid answers are ONLY 'Estadio I''Estadio II''Estadio III''Estadio IV'",
  "THE ONLY RETURN PROMPT IS THOSE TWO WORDS REGARDING STAGE, provide no further explanation")

#
#opcion con prompt no restrictivo ######
t1long_20<-Sys.time() 
extract_sample_long<-sample_noest |>
  llm_custom(resumen_de_historia_clinica, my_prompt)
tflong20<- Sys.time()
tf_final_long20<-tflong20-t1long_20
tf_final_long20

tf_final_long20*(nrow(datos_no_estadio)/20)

# 
# Time difference of 16.18 mins
# > 
#   > tffred_20*(nrow(datos_no_estadio)/20)
# Time difference of 10682 mins
# > 10682/60
# [1] 178
# > 10682/60/10
# [1] 17.8
########


#prompts que restirngen el tamaño final. 
t1_20<-Sys.time() 
extract_sample_long<-sample_noest|>
  llm_custom(resumen_de_historia_clinica, my_prompt_red)
tfred_20<- Sys.time()
tffred_20<-tfred_20-t1_20
tffred_20



extract_sample_long  %>% write.csv("./HCSC/Proyectos ONCO/PPS/EOCI/ONCO_FORMULARIOS/20try_LLMsample_reduced prompt2.csv")


# TODA LA DATA
t1_20<-Sys.time() 
extract_nostage<-datos_no_estadio|>
  llm_custom(resumen_de_historia_clinica, my_prompt_red)
tfred_20<- Sys.time()
tffred_20<-tfred_20-t1_20
tffred_20

(tffred_20*(nrow(datos_no_estadio)/20))/60


############future map  NOT WORKING
install.packages("furrr")
library(furrr)
library(parallel)


future::plan(multisession, workers=detectCores() - 1)
alphas<-seq(0,1,by=0.1)

set.seed(12345)

llm_use("ollama", "llama3.1", seed = 100, temperature = 0)







#cannot be parallelized 
#map o pmap?¿
result <- sample_noest |> 
  future_pmap(
    ~ llm_vec_custom(..2, my_prompt_red)
    # , 
    # .progress = TRUE # Optional: Show progress bar
  )
result <- sample_noest |> 
  future_pmap(
    ~ llm_vec_custom(..2, my_prompt_red)
    # , 
    # .progress = TRUE # Optional: Show progress bar
  )
?llm_vec_custom
#to break
plan(sequential)

#codeoriginal Melina
# 
# tunningEnet<- future_map(alphas,
#                          function(a) cv.glmnet(x,y,nfolds=5,family = "binomial",
#                                                alpha=a, type.measure="auc"),
#                          .options = furrr_options(seed = T))