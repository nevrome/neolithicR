#### load libraries ####
library(DiagrammeR)
library(magrittr)

#### source dbs ####
sourceid <- 1:4
sourcelabel <- c("CALPAL", "aDRAC", "EUROEVOL", "RADON")

sourcedbs <- create_nodes(
  sourceid,
  label = sourcelabel
)

#### target db ####
targetid <- max(sourceid) + 1
targetlabel <- c("Internal SQLite Database")

targetdb <- create_nodes(
  targetid,
  label = targetlabel
)

#### connect source dbs and target db ####
dbcons <- create_edges(
  from = sourceid,
  to = rep(targetid, length(sourceid))   
)

#### app ####
appid <- max(targetid) + 1
applabel <- c("neolithicRC")

app <- create_nodes(
  appid,
  label = applabel
)

#### connect target db and app ####
appcons <- create_edges(
  from = targetid,
  to = appid   
)

#### db modifiers ####
dbmodid <- (max(appid) + 1):((max(appid) + 1) + 1) 
dblabels <- c("14C Calibration", "Spatial Quality Estimation")

dbmod <- create_nodes(
  dbmodid,
  label = dblabels
)

tvec <- rep(targetid, length(dbmodid))

dbmodcons <- create_edges(
  from = c(tvec, dbmodid),
  to = c(dbmodid, tvec)
)

#### thesaurus ####

thesaurusid <- max(dbmodid) + 1
thesauruslabel <- c("thesaurus")

thesaurus <- create_nodes(
  thesaurusid,
  label = thesauruslabel
)

thesauruscons <- create_edges(
  from = c(targetid, thesaurusid),
  to = c(thesaurusid, appid)
)

#### draw graph #####
graph <-
  create_graph() %>%
  add_node_df(sourcedbs) %>%
  add_node_df(targetdb) %>%
  add_edge_df(dbcons) %>%
  add_node_df(app) %>%
  add_edge_df(appcons) %>%
  add_node_df(dbmod) %>%
  add_edge_df(dbmodcons) %>%
  add_node_df(thesaurus) %>%
  add_edge_df(thesauruscons)
  

render_graph(graph)

