#' Internal: parse DataTables server-side request (query string to list)
#' @keywords internal
.dt2_parse_ssp_request <- function(req, n_cols) {
  qs <- req$QUERY_STRING %||% ""
  if (is.null(qs) || identical(qs, "")) return(list(draw = 1L, start = 0L, length = 10L))

  kv <- strsplit(qs, "&", fixed = TRUE)[[1]]
  kv <- kv[nzchar(kv)]
  parts <- strsplit(kv, "=", fixed = TRUE)
  parts <- lapply(parts, function(x) utils::URLdecode(if (length(x) == 2) x[2] else ""))

  keys <- vapply(strsplit(kv, "=", fixed = TRUE), `[[`, character(1), 1)
  q <- stats::setNames(parts, keys)

  num <- function(x, default = NA_integer_) {
    y <- suppressWarnings(as.integer(x))
    ifelse(is.na(y), default, y)
  }

  draw   <- num(q[["draw"]],   1L)
  start  <- num(q[["start"]],  0L)
  length <- num(q[["length"]], 10L)

  # global search
  search_value <- q[["search[value]"]]
  search_regex <- isTRUE(q[["search[regex]"]] %in% c("true", "TRUE", "1"))

  # ordering (podem existir múltiplas entradas order[i][...])
  # coletamos pares (column, dir) por i = 0..n
  ord <- list()
  for (i in 0:max(0, n_cols - 1)) {
    col_key <- sprintf("order[%d][column]", i)
    dir_key <- sprintf("order[%d][dir]", i)
    if (!is.null(q[[col_key]]) && !is.null(q[[dir_key]])) {
      ord[[length(ord) + 1]] <- list(
        column = num(q[[col_key]], 0L) + 1L,  # 1-based em R
        dir    = if (tolower(q[[dir_key]]) %in% c("desc", "descending")) "desc" else "asc"
      )
    }
  }

  list(
    draw = draw, start = start, length = length,
    search = list(value = search_value, regex = search_regex),
    order = ord
  )
}

#' Internal: build DataTables JSON payload
#' @keywords internal
.dt2_payload <- function(draw, total, filtered, data_rows) {
  list(
    draw = draw,
    recordsTotal = as.integer(total),
    recordsFiltered = as.integer(filtered),
    data = data_rows
  )
}

#' Default server-side handler (filter/order/page)
#'
#' @param names character() column names in display order.
#' @return function(data, req) -> list(draw, recordsTotal, recordsFiltered, data)
#' @export
dt2_ssp_handler <- function(names) {
  force(names)
  function(data, req) {
    stopifnot(is.data.frame(data))
    n_cols <- length(names)
    pars <- .dt2_parse_ssp_request(req, n_cols)

    draw   <- pars$draw
    start  <- max(0L, pars$start)
    length <- max(0L, pars$length)
    idx_cols <- names

    # base
    df <- data

    # search global (case-insensitive, não regex por padrão)
    if (!is.null(pars$search$value) && nzchar(pars$search$value)) {
      pat <- tolower(pars$search$value)
      keep <- Reduce(`|`, lapply(df[idx_cols], function(col) {
        tolower(as.character(col)) |> grepl(pat, ., fixed = TRUE)
      }))
      df <- df[keep, , drop = FALSE]
    }

    # ordering (aplica em cascata)
    if (length(pars$order)) {
      for (ord in rev(pars$order)) { # último primeiro para estabilidade
        j <- max(1L, min(n_cols, ord$column))
        nm <- idx_cols[j]
        if (ord$dir == "desc") {
          df <- df[order(df[[nm]], decreasing = TRUE, na.last = TRUE), , drop = FALSE]
        } else {
          df <- df[order(df[[nm]], decreasing = FALSE, na.last = TRUE), , drop = FALSE]
        }
      }
    }

    total <- nrow(data)
    filt  <- nrow(df)

    # paginação
    if (length >= 0) {
      i1 <- start + 1L
      i2 <- min(filt, start + length)
      if (i1 <= i2 && filt > 0) df <- df[i1:i2, , drop = FALSE] else df <- df[0, , drop = FALSE]
    }

    # retorna como array de objetos (chaves = nomes)
    rows <- lapply(seq_len(nrow(df)), function(i) {
      as.list(stats::setNames(df[i, idx_cols, drop = TRUE], idx_cols))
    })

    .dt2_payload(draw, total, filt, rows)
  }
}

#' Bind a DataTables v2 server-side endpoint to a widget id
#'
#' @param id Output id of the widget (e.g., "tbl").
#' @param data A data.frame with the source data.
#' @param session Shiny session (default: current).
#' @param handler Optional custom handler function(data, req) -> list(...).
#' @export
dt2_bind_server <- function(id, data, session = shiny::getDefaultReactiveDomain(), handler = NULL) {
  stopifnot(!is.null(session), is.character(id), length(id) == 1)
  stopifnot(is.data.frame(data))
  # nomes em exibição; se o JS recebeu options$columns, use-os
  col_names <- names(data)
  handler <- handler %||% dt2_ssp_handler(col_names)

  req_name  <- paste0(id, "_server_req")
  resp_name <- paste0(id, "_server_resp")

  shiny::observeEvent(session$input[[req_name]], {
    req <- session$input[[req_name]]
    # Shim "req" com QUERY_STRING (htmlwidgets v1.6+ envia objeto; nós montamos uma string)
    qs <- req$queryString %||% ""  # nosso dt2.js envia request + queryString
    fake_req <- list(QUERY_STRING = qs)

    payload <- handler(data, fake_req)
    session$sendCustomMessage(resp_name, payload)
  }, ignoreInit = TRUE, priority = 10)
}
