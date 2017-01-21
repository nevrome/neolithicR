#### load libraries ####
library(RSQLite)

#### load data ####
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

#### create thesaurus table and add() ####
COUNTRY_thesaurus <- data.frame()
add <- function(vec, term) {
  COUNTRY_thesaurus <<- rbind(
    COUNTRY_thesaurus, 
    data.frame(cor = rep(term, length(vec)), var = vec, stringsAsFactors = FALSE)
  )
}

#### variants ####
unknown <- c(
  "",
  "n/a",
  "nd",
  "NoCountry",
  "probably Ireland?", 
  "NA"
)
add(unknown, "unknown")

Andorra <- c(
  "Andora"
)
add(Andorra, "Andorra")

Israel <- c(
  "Israel/Palestina",
  "Israel, Palestine",
  "Israel",
  "West Bank",
  "Gaza"
)
add(Israel, "Israel and Palestine")

Egypt <- c(
  "Egypt_Sinai"
)
add(Egypt, "Egypt")

Yugoslavia <- c(
  "SFRY",
  "Yugoslavia"
)
add(Yugoslavia, "Yugoslavia")

Central_African_Republic <- c(
  "CAF",
  "Central African Republic"
)
add(Central_African_Republic, "Central African Republic")

Gabon <- c(
  "GAB"
)
add(Gabon, "Gabon")

Congo <- c(
  "COG",
  "Republic of the Congo"
)
add(Congo, "Congo")

Democratic_Republic_of_the_Congo <- c(
  "COD",
  "Democratic Republic of the Congo"
)
add(Democratic_Republic_of_the_Congo, "Democratic Republic of the Congo")

Rwanda <- c(
  "RWA"
)
add(Rwanda, "Rwanda")

Cameroon <- c(
  "CMR",
  "Cameroon"
)
add(Cameroon, "Cameroon")

Chad <- c(
  "TCD"
)
add(Chad, "Chad")

Equatorial_Guinea <- c(
  "GNQ"
)
add(Equatorial_Guinea, "Equatorial Guinea")

Ghana <- c(
  "GHA",
  "Ghana"
)
add(Ghana, "Ghana")

Angola <- c(
  "AGO"
)
add(Angola, "Angola")

Burundi <- c(
  "BDI"
)
add(Burundi, "Burundi")

United_Arab_Emirates <- c(
  "U.A.E.",
  "United Arab Emirates"
)
add(United_Arab_Emirates, "United Arab Emirates")

United_Kingdom <- c(
  "Great Britain",
  "United Kingdom",
  "England/Wales",
  "Scotland",
  "Isle of Man",
  "Channel Isles",
  "Guernsey",
  "Jersey",
  "Wales"
)
add(United_Kingdom, "United Kingdom")

Cyprus <- c(
  "Cyprus",
  "Akrotiri Sovereign Base Area",
  "Northern Cyprus"
)
add(Cyprus, "Cyprus")

Macedonia <- c(
  "Macedonia",
  "Republic of Macedonia"
)
add(Macedonia, "Macedonia")

Serbia <- c(
  "Serbia",
  "Serbia and Montenegro",
  "Montenegro",
  "Republic of Serbia"
)
add(Serbia, "Serbia and Montenegro")

Finland <- c(
  "Finland",
  "Aland",
  "Åland Islands"
)
add(Finland, "Finland")

Italy <- c(
  "Italy",
  "Sardinia"
)
add(Italy, "Italy")

Bosnia <- c(
  "Bosnia and Herzegovina",
  "Bosnia-Herzegovine"
)
add(Bosnia, "Bosnia and Herzegovina")

#### test if thesaurus has independent values ####
if(
  unique(datestable$COUNTRY) %in% 
  COUNTRY_thesaurus$var %>%
  all %>%
  `!`
) {warning(
    "The country thesaurus has independent values! 
    (that's ok - just FYI)"
  )
}

# what is independent?
# unique(datestable$COUNTRY)[
#   unique(datestable$COUNTRY) %in%
#     COUNTRY_thesaurus$var %>%
#     `!`
# ] %>% sort

#### add already correct values ####
varlist <- unique(datestable$COUNTRY)
for (i in 1:length(varlist)){
  if(!(varlist[i] %in% COUNTRY_thesaurus$var)) {
    add(varlist[i], varlist[i])
  }
}

#### save thesaurus table ####
save(COUNTRY_thesaurus, file = "modules/radiocarbon5/thesauri/COUNTRY_thesaurus.RData")