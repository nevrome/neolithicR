#### load data ####
library(RSQLite)
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

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
  "antler", "antler "
)
add(antler, "antler")

ash <- c(
  "ash", "ashy soil"
)
add(ash, "ash")

bark <- c(
  "bark",
  "Rinde", "riinde"
)
add(bark, "bark")

brain <- c(
  "brain", "brain tissue"
)
add(brain, "brain")

bone <- c(
  "bone", "bone ", "bones", "Bone",
  "cremated bones",
  "human bone",
  "collagen, bone", "collagen",
  "bone, rib",
  "bone/apatit",
  "bone/collagen",
  "animal bone", "Animal Bone",
  "bone (Bos taurus)", "bos", "Ur",
  "bone (Sus domestica)",
  "bone (Sus scrofa)",
  "aegilops (saiga)",
  "pig",
  "hueso"
)
add(bone, "bone")

ceramics <- c(
  "pottery", "ceramics",
  "organic temper", "vegetable temper"
)
add(ceramics, "ceramics")

charcoal <- c(
  "charcoal", "charcol",
  "charred wood",
  "charcoal ", "charoal", "charcoal      ", "charcoal         ", "charcoak", "charcoalE", "charcoal/roots", "Charcoal",
  "charcoal, charred plant macrofossils",
  "charred material"
)
add(charcoal, "charcoal")

fabric <- c(
  "cloth",
  "fabric",
  "leather",
  "mat", 
  "textile",
  "thread     ",
  "wool"
)
add(fabric, "fabric")

faeces <- c(
  "dung",
  "excrement",
  "rat dropping"
)
add(faeces, "faeces")

food <- c(
  "Speisereste", "food", "food remains", "food residue", "charred food residue",
  "bread", 
  "cereal",
  "fruit",
  "grapes",
  "Honey",
  "legumes", "legume",
  "voedselrest" #Speisereste
)
add(food, "food")

hair <- c(
  "animal hair",
  "hair"
)
add(hair, "hair")

horn <- c(
  "horn",
  "hjorthorn" #Hirschhorn
)
add(horn, "horn")

plant <- c(
  "plant Remains", "plant macrofossils", "plantenvezels", "plant", "plant matter", 
  "plant remains", "plant Remains", "plants", "burnt plants",
  "triticum", "barley", "T.dicoccum",
  "wheat, chickpeas", 
  "seed", "Seed", "seed/fruit", "seeds", "seeds/fruit",
  "Elaeis guineensis",
  "bean", "beans", "been","peas",
  "Pennisetum glaucum",
  "Nauclea sp.",
  "Canarium s.",
  "Cornus mas",
  "Gilbertiodendron d.",
  "grain",
  "grass", "reed", "reed       ","reed         ", "reed+twig  ", "straw+reed ", "grass      ", "grass+straw", 
  "grape",
  "acorn", "acorns", "Acorns",
  "apple",
  "bine",
  "Tannenreisig I", "Tannenreisig II", "Tannenreisig III",
  "Charred twig", "charred twigs", "charred reed", 
  "charred plant macrofossils",
  "notenschelpen (verkoold)", #Nusschalen
  "hazelnut", "hazelnoot", "hazelnutshell", "pistaca", "nuts or peas", "nut", "nutshell",
  "gerste", 
  "grain ", "grain, chickpeas",
  "Lolium sp.",
  "straw      ",
  "charred seeds",
  "papyrus",
  "linen",
  "moss",
  "olive stone",
  "grain  ", "cereals",
  "fruit/seeds", "charred fruit",
  "eichelbruch", "Eicheln ", "Eicheln and grain",
  "fabacae",
  "figs",
  "linsen", "lenses", "grain, lenses, peas", "charred seed"
)
add(plant, "plant remains")

shell <- c(
  "Shell (River/Ocean)", "Shell (Land)", "shells", "shell ", "shell",
  "coquille",
  "mollusc",  "molluscs", "marine mollusks",
  "Escargotière",
  "ostrich eggs", "ostrich egg", "eggshell"
)
add(shell, "shell")

soil <- c(
  "sediment", "Sediment",
  "humus", "humic acid", "humic acids", "humic",
  "soil", "soil ",
  "Peat", "peat","peat ", "gyttja", "torv",
  "organic sediment",
  "Gyttja",
  "tuf", 
  "pedogenic carbonate",
  "pigment",
  "rotlehm", "Rotlehm",
  "Sand",
  "stones",
  "veen"
)
add(soil, "soil")

soot <- c(
  "soot"
)
add(soot, "soot")

teeth <- c(
  "teeth", "tooth", 
  "dentin"
)
add(teeth, "teeth")

tissue <- c(
  "tissue",
  "skin"
)
add(tissue, "tissue")

unknown <- c(
  "k. A.",
  "n/a",
  "",
  "nd",
  " nd",
  "miscellaneous",
  "charcoal?",
  "NULL",
  "AH",
  "B",
  "bd",
  "Br         ",
  "bone?",
  "c",
  "Er",
  "Fl         ",
  "Ln", "Ln         ",
  "Sn         ",
  "see",
  "short-lived",
  "other",
  "carbonised residue", "carbonate", "organic residue",
  "organic matter", "organic substance", "organic", "organic ", "organic  ", "organic   ",
  "tar", "lump of tar",
  "lens",
  "humates    ",
  "residue",
  "leister prong",
  "charcoal or shell",
  "Hearth", "hearth",
  "tand, ko",
  "carbon"
)
add(unknown, "unknown")

wood <- c(
  "wood", "wood ", "wood  ", "wood      ", "wood       ", "wood         ",
  "carbonised wood/ash", "carbonised wood",
  "Dendro",
  "twigs", "twig",
  "Haselzweig",
  "resin",
  "schors (verkoold)", #Rinde
  "tree ",
  "wicker", 
  "lindbast",
  "Populus sp.",
  "Axtschaft",
  "lieg.wood"
)
add(wood, "wood")


#### add already correct values ####
varlist <- unique(datestable$MATERIAL)
for (i in 1:length(varlist)){
  if(!(varlist[i] %in% MATERIAL_thesaurus$var)) {
    add(varlist[i], varlist[i])
  }
}

#### save thesaurus table ####
save(MATERIAL_thesaurus, file = "modules/radiocarbon5/thesauri/MATERIAL_thesaurus.RData")