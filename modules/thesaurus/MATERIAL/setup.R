# library(RSQLite)
# con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
# datestable = dbGetQuery(con, 'select * from dates')

#### create thesaurus table and add function ####
MATERIAL_thesaurus <- data.frame()
add <- function(vec, term) {
  MATERIAL_thesaurus <<- rbind(
    MATERIAL_thesaurus, 
    data.frame(cor = rep(term, length(vec)), var = vec, stringsAsFactors = FALSE)
  )
}

#### variants ####
antler <- c(
  "antler",
  "antler "
)
add(antler, "antler")

bark <- c(
  "riinde",
  "Rinde"
)
add(bark, "bark")

brain <- c(
  "brain tissue",
  "brain"
)
add(brain, "brain")

bone <- c(
  "bone",
  "bone ",
  "cremated bones",
  "bone, rib",
  "bone/apatit",
  "bones",
  "bone/collagen",
  "Bone",
  "teeth", "tooth", 
  "animal bone",
  "Animal Bone",
  "bone (Bos taurus)", "bos",
  "bone (Sus domestica)",
  "bone (Sus scrofa)"
)
add(bone, "bone")

charcoal <- c(
  "charcoal",
  "charcol",
  "charred wood",
  "charcoal ",
  "charoal",
  "charcoal      ",
  "charcoal         ",
  "charcoak",
  "charcoalE",
  "charcoal/roots",
  "Charcoal",
  "charcoal, charred plant macrofossils",
  "charred material"
)
add(charcoal, "charcoal")

plant <- c(
  "plant Remains", "plant macrofossils", "plantenvezels", "plant", "plant matter", 
  "plant remains", "plant Remains", "plants",
  "triticum", "barley", "T.dicoccum",
  "wheat, chickpeas", 
  "seed", "Seed", "seed/fruit", "seeds", "seeds/fruit",
  "Elaeis guineensis",
  "bean", "beans", "been","peas",
  "Pennisetum glaucum",
  "Nauclea sp.",
  "Canarium s.",
  "Gilbertiodendron d.",
  "grass", "reed", "reed       ","reed         ", "reed+twig  ", "straw+reed ", 
  "grape",
  "acorn", "acorns", "Acorns",
  "apple",
  "bine",
  "Tannenreisig I", "Tannenreisig II", "Tannenreisig III"
)
add(plant, "plant remains")

shell <- c(
  "Shell (River/Ocean)",
  "Shell (Land)",
  "coquille",
  "mollusc",
  "molluscs",
  "Escargotière",
  "shells",
  "shell " 
)
add(shell, "shell")

soil <- c(
  "sediment",
  "humus",
  "soil ",
  "Peat"
)
add(soil, "soil")

unknown <- c(
  "k. A.",
  "",
  "nd",
  " nd",
  "charcoal?",
  "NULL",
  "AH",
  "B",
  "bd",
  "bone?",
  "c",
  "Er",
  "Fl         ",
  "Ln",
  "Ln         ",
  "Sn         ",
  "see",
  "short-lived",
  "other" 
)
add(unknown, "unknown")

wood <- c(
  "wood",
  "wood ",
  "wood  ",
  "wood      ",
  "wood       ",
  "wood         ",
  "twigs",
  "twig"
)
add(wood, "wood")

#### save thesaurus table ####
MATERIAL <- MATERIAL_thesaurus
save(MATERIAL, file = "modules/thesaurus/MATERIAL/MATERIAL_thesaurus.RData")