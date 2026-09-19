#' Internal: parse DataTables server-side request (query string to list)
#' @keywords internal
.dt2_parse_ssp_request <- function(req, n_cols) {
  qs <- req$QUERY_STRING %||% ""
  if (is.null(qs) || identical(qs, "")) return(list(draw = 1L, start = 0L, length = 10L))

  kv <- strsplit(qs, "&", fixed = TRUE)[[1]]
  kv <- kv[nzchar(kv)]
  parts <- strsplit(kv, "=", fixed = TRUE)
  parts <- lapply(parts, function(x) utils::URLdecode(if (length(x) == 2) x[2] else ""))

  # Keys must be URL-decoded too: dt2.js encodes them with encodeURIComponent,
  # so e.g. "search[value]" arrives as "search%5Bvalue%5D" and bracketed
  # order keys as "order%5B0%5D%5Bcolumn%5D". Decoding here lets the lookups
  # below (q[["search[value]"]], "order[i][column]") match.
  keys <- vapply(strsplit(kv, "=", fixed = TRUE),
                 function(x) utils::URLdecode(x[[1]]), character(1))
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
#'
#' `rows_all` / `rows_current` (1-based indices into the source data) are
#' optional; when supplied they are shipped as `dt2_rows_all` /
#' `dt2_rows_current` and dt2.js forwards them to `input$<id>_rows_all` /
#' `input$<id>_rows_current`.
#' @keywords internal
.dt2_payload <- function(draw, total, filtered, data_rows,
                         rows_all = NULL, rows_current = NULL) {
  out <- list(
    draw = draw,
    recordsTotal = as.integer(total),
    recordsFiltered = as.integer(filtered),
    data = data_rows
  )
  if (!is.null(rows_all))     out$dt2_rows_all     <- I(as.integer(rows_all))
  if (!is.null(rows_current)) out$dt2_rows_current <- I(as.integer(rows_current))
  out
}

#' Default server-side handler (filter/order/page)
#'
#' @param names character() column names in display order.
#' @param rows_all Logical. If `TRUE` (default), the response also carries the
#'   1-based indices (into the source data) of all rows that survive the
#'   current filter (`dt2_rows_all`) and of the rows on the current page
#'   (`dt2_rows_current`). dt2.js forwards them to `input$<id>_rows_all` and
#'   `input$<id>_rows_current`, mirroring the client-side behaviour. Set to
#'   `FALSE` for very large tables, where shipping the full index vector on
#'   every draw is too costly; the two inputs are then `NULL`.
#' @return function(data, req) -> list(draw, recordsTotal, recordsFiltered,
#'   data, and optionally dt2_rows_all, dt2_rows_current)
#' @export
dt2_ssp_handler <- function(names, rows_all = TRUE) {
  force(names)
  rows_all <- isTRUE(rows_all)
  function(data, req) {
    stopifnot(is.data.frame(data))
    n_cols <- length(names)
    pars <- .dt2_parse_ssp_request(req, n_cols)

    draw   <- pars$draw
    start  <- max(0L, pars$start)
    length <- max(0L, pars$length)
    idx_cols <- names

    # base; `idx` tracks the original row numbers through filter/order/page
    df  <- data
    idx <- seq_len(nrow(data))

    # search global (case-insensitive, não regex por padrão)
    if (!is.null(pars$search$value) && nzchar(pars$search$value)) {
      pat <- tolower(pars$search$value)
      keep <- Reduce(`|`, lapply(df[idx_cols], function(col) {
        grepl(pat, tolower(as.character(col)), fixed = TRUE)
      }))
      keep <- !is.na(keep) & keep
      df  <- df[keep, , drop = FALSE]
      idx <- idx[keep]
    }

    # ordering (aplica em cascata)
    if (length(pars$order)) {
      for (ord in rev(pars$order)) { # último primeiro para estabilidade
        j <- max(1L, min(n_cols, ord$column))
        nm <- idx_cols[j]
        o  <- order(df[[nm]], decreasing = identical(ord$dir, "desc"), na.last = TRUE)
        df  <- df[o, , drop = FALSE]
        idx <- idx[o]
      }
    }

    total <- nrow(data)
    filt  <- nrow(df)
    all_idx <- idx

    # paginação
    if (length >= 0) {
      i1 <- start + 1L
      i2 <- min(filt, start + length)
      sel <- if (i1 <= i2 && filt > 0) i1:i2 else integer(0)
      df  <- df[sel, , drop = FALSE]
      idx <- idx[sel]
    }

    # retorna como array de objetos (chaves = nomes)
    rows <- lapply(seq_len(nrow(df)), function(i) {
      as.list(stats::setNames(df[i, idx_cols, drop = TRUE], idx_cols))
    })

    if (rows_all) {
      .dt2_payload(draw, total, filt, rows, rows_all = all_idx, rows_current = idx)
    } else {
      .dt2_payload(draw, total, filt, rows)
    }
  }
}

#' Bind a DataTables v2 server-side endpoint to a widget id
#'
#' @param id Output id of the widget (e.g., "tbl").
#' @param data A data.frame with the source data.
#' @param session Shiny session (default: current).
#' @param handler Optional custom handler function(data, req) -> list(...).
#'   A custom handler may include `dt2_rows_all` / `dt2_rows_current`
#'   (1-based row indices) in its result to feed `input$<id>_rows_all` and
#'   `input$<id>_rows_current`; see [dt2_ssp_handler()].
#' @param rows_all Passed to [dt2_ssp_handler()] when `handler` is `NULL`:
#'   whether the default handler ships the filtered row indices to the client.
#' @return No return value, called for side effects. Registers a Shiny
#'   observer on `session` that responds to client-side server-processing
#'   requests for the given widget `id`.
#' @export
dt2_bind_server <- function(id, data, session = shiny::getDefaultReactiveDomain(),
                            handler = NULL, rows_all = TRUE) {
  stopifnot(!is.null(session), is.character(id), length(id) == 1)
  stopifnot(is.data.frame(data))
  # nomes em exibição; se o JS recebeu options$columns, use-os
  col_names <- names(data)
  handler <- handler %||% dt2_ssp_handler(col_names, rows_all = rows_all)

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
