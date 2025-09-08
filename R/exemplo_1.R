library(DT2plus)

dt2(
  iris,
  options = dt2_options(
    paging = TRUE,
    page_length = 10,
    searching = TRUE,
    responsive = TRUE
  )
)


library(htmlwidgets)

x <- list(
  data = iris,
  options = list(paging = TRUE, pageLength = 10, searching = TRUE, responsive = TRUE),
  serverSide = FALSE,
  columns = names(iris)
)

htmlwidgets::createWidget(
  name = "dt2",
  x = x,
  width = 960,
  height = 500,
  package = "DT2" # ou "" se estiver testando manualmente
)



options(DT2.use_cdn = FALSE)
options(DT2.dt_version = "2.3.3")
options(DT2.ext_versions = list(buttons="3.2.4", select="3.0.1", responsive="3.0.6"))

htmlwidgets::createWidget(
  name = "dt2",
  x = x,
  width = width,
  height = height,
  package = "DT2",
  dependencies = c(
    list(dt2_depend()),
    dt2_dependency_extensions(extensions)
  )
)

options(DT2.use_cdn = FALSE)
w <- dt2(iris, options = list(paging = TRUE), extensions = c("select","responsive"))


# selfcontained = TRUE embarca JS/CSS no próprio HTML (100% offline)
htmlwidgets::saveWidget(w, "teste_offline.html", selfcontained = TRUE)


library(DT2)
w <- dt2(iris, options = list(paging=TRUE, pageLength=10),
         extensions = c("select","responsive"))
htmlwidgets::saveWidget(w, "teste_offline.html", selfcontained = TRUE)

options(DT2.use_cdn)
options(DT2.use_cdn = FALSE)
w <- dt2(cars, options = list(paging=TRUE, pageLength=10))
htmlwidgets::saveWidget(w, "ok.html", selfcontained = TRUE)


library(DT2)
w <- dt2(iris, options = list(paging = TRUE, pageLength = 10))
htmlwidgets::saveWidget(w, "ok.html", selfcontained = TRUE)

htmlwidgets::saveWidget(dt2(iris, options = list(pageLength = 10)), "ok.html", selfcontained = TRUE)

htmlwidgets::saveWidget(dt2(iris), "ok.html", selfcontained = TRUE)



