# app.R
library(shiny)
library(bslib)
library(DT2)

# --- idioma PT-BR básico ---
lang_pt <- list(
  lengthMenu = "Linhas por página",     # rótulo do controle
  search   = "Buscar:",
  paginate = list(previous = "Anterior", `next` = "Próximo"),
  info     = "Mostrando _START_ até _END_ de _TOTAL_ registros"
)

# --- dados de teste ---
iris_small <- head(iris, 12)
cars_df    <- head(cars, 10)
mtcars_big <- do.call(rbind, replicate(50, mtcars, simplify = FALSE)) # p/ scroller

# --- helpers para reduzir repetição ---
panel_tbl <- function(id) {
  tagList(
    DT2::dt2_output(id),
    tags$hr(class = "my-3"),
    verbatimTextOutput(paste0(id, "_state"))
  )
}

render_state <- function(id) {
  renderPrint({ get(paste0(id, "_state"), envir = parent.frame(), inherits = TRUE) })
}

ui <- bslib::page_navbar(
  title = "DT2 – extensões (Bootstrap 5)",
  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "flatly" # mude se quiser (cosmo, minty, litera, etc.)
  ),
  sidebar = NULL,

  # Cada nav_panel é uma "aba" real com CSS/JS corretos do Bootstrap 5 (via bslib)
  bslib::nav_panel("Core", panel_tbl("core")),
  bslib::nav_panel("Select", panel_tbl("sel")),
  bslib::nav_panel("Buttons", panel_tbl("btn")),
  bslib::nav_panel("Responsive", panel_tbl("resp")),
  bslib::nav_panel("ColReorder + FixedHeader", panel_tbl("reord_fixhdr")),
  bslib::nav_panel("FixedColumns (esq/dir)", panel_tbl("fixcols")),
  bslib::nav_panel("KeyTable", panel_tbl("keytab")),
  bslib::nav_panel("RowGroup + RowReorder", panel_tbl("group_reorder")),
  bslib::nav_panel("Scroller (virtual)", panel_tbl("scroll")),
  bslib::nav_panel("SearchPanes + SearchBuilder", panel_tbl("search")),
  bslib::nav_panel("AutoFill", panel_tbl("fill")),
  bslib::nav_panel("StateRestore", panel_tbl("state"))
)

server <- function(input, output, session) {

  # -------- Core ------------------------------------------------------------
  output$core <- DT2::render_dt2({
    DT2::dt2(
      data    = iris_small,
      options = list(
        # >>> NUNCA defina 'dom' aqui se for usar layout do v2 <<<
        lengthChange = TRUE,       # deixa o controle habilitado
        pageLength   = 5,

        layout = list(
          topStart = list(
            pageLength = list(
              # valores e labels (note os DOIS vetores em uma lista)
              menu  = list(
                c(5, 10, 25, 50, -1),
                c("5", "10", "25", "50", "Todos")
              ),
              label = "Linhas por página"
            )
          ),
          topEnd = list(
            search = list(placeholder = "Buscar:")
          )
        ),

        language = list(
          lengthMenu = "Linhas por página",
          search     = "Buscar:",
          paginate   = list(previous = "Anterior", `next` = "Próximo"),
          info       = "Mostrando _START_ até _END_ de _TOTAL_ registros"
        )
      ),
      extensions = character(0)
    )
  })
  output$core_state <- renderPrint({ input$core_state })

  # -------- Select ----------------------------------------------------------
  output$sel <- DT2::render_dt2({
    DT2::dt2(
      data    = iris_small,
      options = list(
        # >>> NUNCA defina 'dom' aqui se for usar layout do v2 <<<
        lengthChange = TRUE,       # deixa o controle habilitado
        pageLength   = 5,

        layout = list(
          topStart = list(
            pageLength = list(
              # valores e labels (note os DOIS vetores em uma lista)
              menu  = list(
                c(5, 10, 25, 50, -1),
                c("5", "10", "25", "50", "Todos")
              ),
              label = "Linhas por página"
            )
          ),
          topEnd = list(
            search = list(placeholder = "Buscar:")
          )
        ),

        language = list(
          lengthMenu = "Linhas por página",
          search     = "Buscar:",
          paginate   = list(previous = "Anterior", `next` = "Próximo"),
          info       = "Mostrando _START_ até _END_ de _TOTAL_ registros"
        )
      ),
      extensions = "select"
    )
  })
  output$sel_state <- renderPrint({ input$sel_state })

  # -------- Buttons ---------------------------------------------------------
  output$btn <- DT2::render_dt2({
    DT2::dt2(
      data    = iris_small,
      options = list(
        columns  = names(iris_small),
        dom      = "Bfrtip",
        buttons  = list("copy", "csv", "print"),
        language = lang_pt
      ),
      extensions = "buttons"
    )
  })
  output$btn_state <- renderPrint({ input$btn_state })

  # -------- Responsive ------------------------------------------------------
  output$resp <- DT2::render_dt2({
    DT2::dt2(
      data    = iris_small,
      options = list(
        columns    = names(iris_small),
        responsive = TRUE,
        pageLength = 5,
        language   = lang_pt
      ),
      extensions = "responsive"
    )
  })
  output$resp_state <- renderPrint({ input$resp_state })

  # -------- ColReorder + FixedHeader ---------------------------------------
  output$reord_fixhdr <- DT2::render_dt2({
    DT2::dt2(
      data    = iris,
      options = list(
        columns     = names(iris),
        colReorder  = TRUE,
        fixedHeader = TRUE,
        pageLength  = 8,
        language    = lang_pt
      ),
      extensions = c("colreorder", "fixedheader")
    )
  })
  output$reord_fixhdr_state <- renderPrint({ input$reord_fixhdr_state })

  # -------- FixedColumns (esq/dir) -----------------------------------------
  output$fixcols <- DT2::render_dt2({
    df <- iris_small
    df$X1 <- df$Sepal.Length
    df$X2 <- df$Sepal.Width
    DT2::dt2(
      data    = df,
      options = list(
        columns      = names(df),
        scrollX      = TRUE,
        fixedColumns = list(leftColumns = 1, rightColumns = 1),
        language     = lang_pt
      ),
      extensions = "fixedcolumns"
    )
  })
  output$fixcols_state <- renderPrint({ input$fixcols_state })

  # -------- KeyTable --------------------------------------------------------
  output$keytab <- DT2::render_dt2({
    DT2::dt2(
      data    = cars_df,
      options = list(
        columns  = names(cars_df),
        keys     = TRUE,
        language = lang_pt
      ),
      extensions = "keytable"
    )
  })
  output$keytab_state <- renderPrint({ input$keytab_state })

  # -------- RowGroup + RowReorder ------------------------------------------
  output$group_reorder <- DT2::render_dt2({
    DT2::dt2(
      data    = iris,
      options = list(
        columns    = names(iris),
        rowGroup   = list(dataSrc = "Species"),
        rowReorder = TRUE,
        language   = lang_pt
      ),
      extensions = c("rowgroup", "rowreorder")
    )
  })
  output$group_reorder_state <- renderPrint({ input$group_reorder_state })

  # -------- Scroller (virtual) ---------------------------------------------
  output$scroll <- DT2::render_dt2({
    DT2::dt2(
      data    = mtcars_big,
      options = list(
        columns     = names(mtcars_big),
        deferRender = TRUE,
        scrollY     = 360,
        scroller    = TRUE,
        pageLength  = 50,
        language    = lang_pt,
        dom         = "frti"   # sem paginação
      ),
      extensions = "scroller"
    )
  })
  output$scroll_state <- renderPrint({ input$scroll_state })

  # -------- SearchPanes + SearchBuilder ------------------------------------
  output$search <- DT2::render_dt2({
    DT2::dt2(
      data    = iris,
      options = list(
        columns       = names(iris),
        dom           = "Plfrtip",         # 'P' = SearchPanes
        searchPanes   = list(cascadePanes = TRUE),
        searchBuilder = TRUE,              # botão 'Filter'
        language      = lang_pt
      ),
      extensions = c("searchpanes", "searchbuilder", "select")
    )
  })
  output$search_state <- renderPrint({ input$search_state })

  # -------- AutoFill --------------------------------------------------------
  output$fill <- DT2::render_dt2({
    DT2::dt2(
      data    = cars_df,
      options = list(
        columns  = names(cars_df),
        autoFill = TRUE,
        language = lang_pt
      ),
      extensions = "autofill"
    )
  })
  output$fill_state <- renderPrint({ input$fill_state })

  # -------- StateRestore (com Buttons) -------------------------------------
  output$state <- DT2::render_dt2({
    DT2::dt2(
      data    = iris_small,
      options = list(
        columns    = names(iris_small),
        stateSave  = TRUE,
        dom        = "Bfrtip",
        buttons    = list("stateRestore", "createState", "savedStates"),
        language   = lang_pt
      ),
      extensions = c("staterestore", "buttons")
    )
  })
  output$state_state <- renderPrint({ input$state_state })
}

shinyApp(ui, server)
