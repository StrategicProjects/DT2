#' Create a DT2 widget (DataTables v2 + Bootstrap 5)
#'
#' @description
#' Core assets (jQuery, DataTables v2 + Bootstrap 5) are declared in the
#' widget YAML. Extensions you packaged there will auto-load. Extra extensions
#' can still be injected with \code{dt2_dependency_extensions()}.
#'
#' If \code{server_side = TRUE}, use \code{\link{dt2_bind_server}} in your
#' Shiny server to attach the transparent server-side pipeline for a given
#' \code{outputId}. This avoids use of non-exported Shiny internals and follows
#' the official DataTables server-side protocol. See examples.
#'
#' @param data A \code{data.frame}. Ignored when \code{server_side = TRUE} **and**
#'   you provide your own \code{options$ajax}.
#' @param options Named list of DataTables options (\code{pageLength}, \code{layout},
#'   \code{language}, etc.). If \code{data} is provided and \code{options$columns}
#'   missing, column names are inferred.
#' @param server_side Logical; enable server-side mode (DataTables \code{serverSide}).
#' @param width,height Widget size.
#' @param elementId Optional id.
#' @param extensions Character vector of extensions to inject on-demand.
#'
#' @return An htmlwidget.
#' @export
dt2 <- function(data = NULL,
                options = list(),
                server_side = FALSE,
                width = NULL,
                height = NULL,
                elementId = NULL,
                extensions = character()) {

  if (!isTRUE(server_side)) {
    if (is.null(data))
      stop("`data` must be provided when `server_side = FALSE`.", call. = FALSE)
    if (is.null(options$columns))
      options$columns <- names(data)
  } else {
    # server-side: se usuário não forneceu ajax, o dt2.js fará a ponte via Shiny
    # (input$id_server_req / customMessage id_server_resp); precisamos só garantir columns
    if (is.null(options$columns) && !is.null(data))
      options$columns <- names(data)
    # NÃO embute os dados no payload quando server-side
    data <- NULL
    # NÃO setamos options$ajax aqui — o dt2.js injeta a função ajax se estiver ausente
  }

  x <- list(
    data       = if (isTRUE(server_side)) NULL else data,
    options    = options,
    serverSide = isTRUE(server_side),
    columns    = options$columns %||% NULL,
    extensions = tolower(unique(extensions))
  )

  deps <- dt2_dependency_extensions(extensions = x$extensions)

  htmlwidgets::createWidget(
    name = "dt2",
    x = x,
    width = width,
    height = height,
    package = "DT2",
    dependencies = deps,
    elementId = elementId
  )
}
