library(shiny)
library(DT2)

ui <- fluidPage(
  titlePanel("DT2: HTML e inputs por linha"),
  DT2::dt2_output("tbl"),
  hr(),
  verbatimTextOutput("eventos")
)

server <- function(input, output, session) {
  df <- head(iris, 10)
  opts <- list(columns = names(df), pageLength = 5, select = TRUE, responsive = TRUE)

  # 1) Exemplo de HTML: link na coluna Species
  opts <- dt2_col_template(opts, "Species", '<a href="/esp/{{VAL}}" class="link-underline">🔗 {{VAL}}</a>')

  # 2) Checkbox por linha na 1ª coluna (apenas para demo)
  opts <- dt2_col_checkbox(opts, 1, input_id_prefix = "chk_")

  # 3) Botão por linha na 2ª coluna
  opts <- dt2_col_button(opts, 2, label = "Detalhes", input_id_prefix = "btn_")

  output$tbl <- DT2::render_dt2({
    DT2::dt2(df, options = opts)
  })

  # Captura dos eventos vindos do JS
  observeEvent(input$tbl_row_check, {
    cat("checkbox:", input$tbl_row_check$row, input$tbl_row_check$value, "\n")
  })
  observeEvent(input$tbl_row_button, {
    cat("button:", input$tbl_row_button$row, input$tbl_row_button$id, "\n")
  })

  output$eventos <- renderPrint({
    list(
      checkbox = input$tbl_row_check,
      button   = input$tbl_row_button
    )
  })

}





library(shiny)
library(DT2)

ui <- fluidPage(
  titlePanel("DT2 smoke test"),
  DT2::dt2_output("tbl"),
  verbatimTextOutput("state"),
  verbatimTextOutput("events")
)

server <- function(input, output, session) {
  df <- head(iris, 12)
  opts <- list(columns = names(df), pageLength = 5, select = TRUE, responsive = TRUE)
  opts <- DT2::dt2_language(opts, lang_list = list(
    search = "Buscar:", paginate = list(previous = "Anterior", `next` = "Próximo"),
    info = "Showing _START_ to _END_ of _TOTAL_ entries"
  ))
  opts <- DT2::dt2_use_buttons(opts, c("copy","csv","excel","print"))
  opts <- DT2::dt2_col_checkbox(opts, 1)
  opts <- DT2::dt2_col_button(opts, 2, label = "Details")
  opts <- DT2::dt2_theme(opts, compact = TRUE, striped = TRUE, hover = TRUE)

  output$tbl <- DT2::render_dt2(DT2::dt2(df, options = opts))

  output$state  <- renderPrint(DT2::dt2_state(input, "tbl"))
  output$events <- renderPrint(list(check = input$tbl_row_check, btn = input$tbl_row_button))
}

shinyApp(ui, server)
shinyApp(ui, server)
