library(magrittr)

datestable <- c14bazAAR::get_all_dates() %>%
  dplyr::sample_n(1000) %>%
  c14bazAAR::as.c14_date_list() %>%
  c14bazAAR::clean() %>%
  c14bazAAR::calibrate() %>%
  c14bazAAR::estimate_spatial_quality() %>%
  c14bazAAR::rm_doubles(mark = TRUE) %>%
  c14bazAAR::thesaurify() %>%
  dplyr::arrange(dplyr::desc(calage)) %>%
  dplyr::mutate(
    maincolor = rainbow(nrow(.), alpha = NULL, start = 0, end = 2/6)
  )

save(datestable, file = "data/c14data.RData")
