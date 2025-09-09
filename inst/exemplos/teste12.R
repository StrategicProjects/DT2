library(jsonlite)
library(dplyr)
library(tibble)
library(lubridate)

# se o JSON estiver em uma string:
json_txt <- '{
  "data": [
    {
      "name": "Tiger Nixon",
      "position": "System Architect",
      "salary": "320800",
      "start_date": "2011-04-25",
      "office": "Edinburgh",
      "extn": "5421"
    },
    {
      "name": "Garrett Winters",
      "position": "Accountant",
      "salary": "170750",
      "start_date": "2011-07-25",
      "office": "Tokyo",
      "extn": "8422"
    },
    {
      "name": "Ashton Cox",
      "position": "Junior Technical Author",
      "salary": "86000",
      "start_date": "2009-01-12",
      "office": "San Francisco",
      "extn": "1562"
    },
    {
      "name": "Cedric Kelly",
      "position": "Senior JavaScript Developer",
      "salary": "433060",
      "start_date": "2012-03-29",
      "office": "Edinburgh",
      "extn": "6224"
    },
    {
      "name": "Airi Satou",
      "position": "Accountant",
      "salary": "162700",
      "start_date": "2008-11-28",
      "office": "Tokyo",
      "extn": "5407"
    },
    {
      "name": "Brielle Williamson",
      "position": "Integration Specialist",
      "salary": "372000",
      "start_date": "2012-12-02",
      "office": "New York",
      "extn": "4804"
    },
    {
      "name": "Herrod Chandler",
      "position": "Sales Assistant",
      "salary": "137500",
      "start_date": "2012-08-06",
      "office": "San Francisco",
      "extn": "9608"
    },
    {
      "name": "Rhona Davidson",
      "position": "Integration Specialist",
      "salary": "327900",
      "start_date": "2010-10-14",
      "office": "Tokyo",
      "extn": "6200"
    },
    {
      "name": "Colleen Hurst",
      "position": "JavaScript Developer",
      "salary": "205500",
      "start_date": "2009-09-15",
      "office": "San Francisco",
      "extn": "2360"
    },
    {
      "name": "Sonya Frost",
      "position": "Software Engineer",
      "salary": "103600",
      "start_date": "2008-12-13",
      "office": "Edinburgh",
      "extn": "1667"
    },
    {
      "name": "Jena Gaines",
      "position": "Office Manager",
      "salary": "90560",
      "start_date": "2008-12-19",
      "office": "London",
      "extn": "3814"
    },
    {
      "name": "Quinn Flynn",
      "position": "Support Lead",
      "salary": "342000",
      "start_date": "2013-03-03",
      "office": "Edinburgh",
      "extn": "9497"
    },
    {
      "name": "Charde Marshall",
      "position": "Regional Director",
      "salary": "470600",
      "start_date": "2008-10-16",
      "office": "San Francisco",
      "extn": "6741"
    },
    {
      "name": "Haley Kennedy",
      "position": "Senior Marketing Designer",
      "salary": "313500",
      "start_date": "2012-12-18",
      "office": "London",
      "extn": "3597"
    },
    {
      "name": "Tatyana Fitzpatrick",
      "position": "Regional Director",
      "salary": "385750",
      "start_date": "2010-03-17",
      "office": "London",
      "extn": "1965"
    },
    {
      "name": "Michael Silva",
      "position": "Marketing Designer",
      "salary": "198500",
      "start_date": "2012-11-27",
      "office": "London",
      "extn": "1581"
    },
    {
      "name": "Paul Byrd",
      "position": "Chief Financial Officer (CFO)",
      "salary": "725000",
      "start_date": "2010-06-09",
      "office": "New York",
      "extn": "3059"
    },
    {
      "name": "Gloria Little",
      "position": "Systems Administrator",
      "salary": "237500",
      "start_date": "2009-04-10",
      "office": "New York",
      "extn": "1721"
    },
    {
      "name": "Bradley Greer",
      "position": "Software Engineer",
      "salary": "132000",
      "start_date": "2012-10-13",
      "office": "London",
      "extn": "2558"
    },
    {
      "name": "Dai Rios",
      "position": "Personnel Lead",
      "salary": "217500",
      "start_date": "2012-09-26",
      "office": "Edinburgh",
      "extn": "2290"
    },
    {
      "name": "Jenette Caldwell",
      "position": "Development Lead",
      "salary": "345000",
      "start_date": "2011-09-03",
      "office": "New York",
      "extn": "1937"
    },
    {
      "name": "Yuri Berry",
      "position": "Chief Marketing Officer (CMO)",
      "salary": "675000",
      "start_date": "2009-06-25",
      "office": "New York",
      "extn": "6154"
    },
    {
      "name": "Caesar Vance",
      "position": "Pre-Sales Support",
      "salary": "106450",
      "start_date": "2011-12-12",
      "office": "New York",
      "extn": "8330"
    },
    {
      "name": "Doris Wilder",
      "position": "Sales Assistant",
      "salary": "85600",
      "start_date": "2010-09-20",
      "office": "Sydney",
      "extn": "3023"
    },
    {
      "name": "Angelica Ramos",
      "position": "Chief Executive Officer (CEO)",
      "salary": "1200000",
      "start_date": "2009-10-09",
      "office": "London",
      "extn": "5797"
    },
    {
      "name": "Gavin Joyce",
      "position": "Developer",
      "salary": "92575",
      "start_date": "2010-12-22",
      "office": "Edinburgh",
      "extn": "8822"
    },
    {
      "name": "Jennifer Chang",
      "position": "Regional Director",
      "salary": "357650",
      "start_date": "2010-11-14",
      "office": "Argentina",
      "extn": "9239"
    },
    {
      "name": "Brenden Wagner",
      "position": "Software Engineer",
      "salary": "206850",
      "start_date": "2011-06-07",
      "office": "San Francisco",
      "extn": "1314"
    },
    {
      "name": "Fiona Green",
      "position": "Chief Operating Officer (COO)",
      "salary": "850000",
      "start_date": "2010-03-11",
      "office": "San Francisco",
      "extn": "2947"
    },
    {
      "name": "Shou Itou",
      "position": "Regional Marketing",
      "salary": "163000",
      "start_date": "2011-08-14",
      "office": "Tokyo",
      "extn": "8899"
    },
    {
      "name": "Michelle House",
      "position": "Integration Specialist",
      "salary": "95400",
      "start_date": "2011-06-02",
      "office": "Sydney",
      "extn": "2769"
    },
    {
      "name": "Suki Burks",
      "position": "Developer",
      "salary": "114500",
      "start_date": "2009-10-22",
      "office": "London",
      "extn": "6832"
    },
    {
      "name": "Prescott Bartlett",
      "position": "Technical Author",
      "salary": "145000",
      "start_date": "2011-05-07",
      "office": "London",
      "extn": "3606"
    },
    {
      "name": "Gavin Cortez",
      "position": "Team Leader",
      "salary": "235500",
      "start_date": "2008-10-26",
      "office": "San Francisco",
      "extn": "2860"
    },
    {
      "name": "Martena Mccray",
      "position": "Post-Sales support",
      "salary": "324050",
      "start_date": "2011-03-09",
      "office": "Edinburgh",
      "extn": "8240"
    },
    {
      "name": "Unity Butler",
      "position": "Marketing Designer",
      "salary": "85675",
      "start_date": "2009-12-09",
      "office": "San Francisco",
      "extn": "5384"
    },
    {
      "name": "Howard Hatfield",
      "position": "Office Manager",
      "salary": "164500",
      "start_date": "2008-12-16",
      "office": "San Francisco",
      "extn": "7031"
    },
    {
      "name": "Hope Fuentes",
      "position": "Secretary",
      "salary": "109850",
      "start_date": "2010-02-12",
      "office": "San Francisco",
      "extn": "6318"
    },
    {
      "name": "Vivian Harrell",
      "position": "Financial Controller",
      "salary": "452500",
      "start_date": "2009-02-14",
      "office": "San Francisco",
      "extn": "9422"
    },
    {
      "name": "Timothy Mooney",
      "position": "Office Manager",
      "salary": "136200",
      "start_date": "2008-12-11",
      "office": "London",
      "extn": "7580"
    },
    {
      "name": "Jackson Bradshaw",
      "position": "Director",
      "salary": "645750",
      "start_date": "2008-09-26",
      "office": "New York",
      "extn": "1042"
    },
    {
      "name": "Olivia Liang",
      "position": "Support Engineer",
      "salary": "234500",
      "start_date": "2011-02-03",
      "office": "Argentina",
      "extn": "2120"
    },
    {
      "name": "Bruno Nash",
      "position": "Software Engineer",
      "salary": "163500",
      "start_date": "2011-05-03",
      "office": "London",
      "extn": "6222"
    },
    {
      "name": "Sakura Yamamoto",
      "position": "Support Engineer",
      "salary": "139575",
      "start_date": "2009-08-19",
      "office": "Tokyo",
      "extn": "9383"
    },
    {
      "name": "Thor Walton",
      "position": "Developer",
      "salary": "98540",
      "start_date": "2013-08-11",
      "office": "New York",
      "extn": "8327"
    },
    {
      "name": "Finn Camacho",
      "position": "Support Engineer",
      "salary": "87500",
      "start_date": "2009-07-07",
      "office": "San Francisco",
      "extn": "2927"
    },
    {
      "name": "Serge Baldwin",
      "position": "Data Coordinator",
      "salary": "138575",
      "start_date": "2012-04-09",
      "office": "Argentina",
      "extn": "8352"
    },
    {
      "name": "Zenaida Frank",
      "position": "Software Engineer",
      "salary": "125250",
      "start_date": "2010-01-04",
      "office": "New York",
      "extn": "7439"
    },
    {
      "name": "Zorita Serrano",
      "position": "Software Engineer",
      "salary": "115000",
      "start_date": "2012-06-01",
      "office": "San Francisco",
      "extn": "4389"
    },
    {
      "name": "Jennifer Acosta",
      "position": "Junior JavaScript Developer",
      "salary": "75650",
      "start_date": "2013-02-01",
      "office": "Edinburgh",
      "extn": "3431"
    },
    {
      "name": "Cara Stevens",
      "position": "Sales Assistant",
      "salary": "145600",
      "start_date": "2011-12-06",
      "office": "New York",
      "extn": "3990"
    },
    {
      "name": "Hermione Butler",
      "position": "Regional Director",
      "salary": "356250",
      "start_date": "2011-03-21",
      "office": "London",
      "extn": "1016"
    },
    {
      "name": "Lael Greer",
      "position": "Systems Administrator",
      "salary": "103500",
      "start_date": "2009-02-27",
      "office": "London",
      "extn": "6733"
    },
    {
      "name": "Jonas Alexander",
      "position": "Developer",
      "salary": "86500",
      "start_date": "2010-07-14",
      "office": "San Francisco",
      "extn": "8196"
    },
    {
      "name": "Shad Decker",
      "position": "Regional Director",
      "salary": "183000",
      "start_date": "2008-11-13",
      "office": "Edinburgh",
      "extn": "6373"
    },
    {
      "name": "Michael Bruce",
      "position": "JavaScript Developer",
      "salary": "183000",
      "start_date": "2011-06-27",
      "office": "Argentina",
      "extn": "5384"
    },
    {
      "name": "Donna Snider",
      "position": "Customer Support",
      "salary": "112000",
      "start_date": "2011-01-25",
      "office": "New York",
      "extn": "4226"
    }
  ]
}'

df <- fromJSON(json_txt, flatten = TRUE)$data %>%   # extrai a lista "data"
  as_tibble() %>%                                   # vira tibble
  mutate(
    salary     = as.numeric(salary),
    extn       = as.integer(extn),
    start_date = ymd(start_date)                    # "YYYY-MM-DD" → Date
  )



library(shiny)
library(bslib)
library(DT2)
library(htmlwidgets)

ui <- page_fluid(
  tags$head(
    # CSS das bandeiras (ajuste para seu arquivo ou sprite preferido)
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "https://cdn.jsdelivr.net/gh/lafeber/world-flags-sprite/stylesheets/flags32-both.css"
    ),
    tags$style(HTML("
      .f32 .flag { display:inline-block; width:32px; height:32px; vertical-align:middle; margin-right:6px; }
      table.dataTable tbody td { vertical-align: middle; }
    "))
  ),
  theme = bs_theme(version = 5, bootswatch = bootswatch_themes(5)[20], font_scale = .9),
  layout_sidebar(
    sidebar = sidebar(
      h4("Ajustes de layout (apenas v2)"),
      p("Sem extensões, sem 'dom'.")
    ),
    card(
      card_header("DT2"),
      dt2_output("example", height = "auto")
    ),
    card(
      card_header("Estado recebido do cliente (debug)"),
      verbatimTextOutput("state")
    )
  )
)

server <- function(input, output, session) {

  # >>> ASSUMA que 'df' já está no ambiente (como você criou na etapa anterior).
  #     Se quiser, pode source() ou construir aqui.

  output$example <- DT2::render_dt2({

    # Renderers JS (assinatura: data, type, row, meta)
    position_js <- htmlwidgets::JS("
      function (data, type, row, meta) {
        if (type === 'display') {
          var link = 'https://datatables.net';
          if (data && data[0] < 'H')      link = 'https://cloudtables.com';
          else if (data && data[0] < 'S') link = 'https://editor.datatables.net';
          return '<a href=\"' + link + '\" target=\"_blank\" rel=\"noopener\">' + data + '</a>';
        }
        return data;
      }
    ")

    office_js <- htmlwidgets::JS("
      function (data, type, row, meta) {
        if (type === 'display') {
          var country = '';
          switch (data) {
            case 'Argentina':    country = 'ar'; break;
            case 'Edinburgh':    country = '_Scotland'; break;
            case 'London':       country = '_England'; break;
            case 'New York':
            case 'San Francisco': country = 'us'; break;
            case 'Sydney':       country = 'au'; break;
            case 'Tokyo':        country = 'jp'; break;
          }
          return '<span class=\"flag ' + country + '\"></span> ' + data;
        }
        return data;
      }
    ")

    extn_js <- htmlwidgets::JS("
      function (data, type, row, meta) {
        return (type === 'display')
          ? '<progress value=\"' + data + '\" max=\"9999\"></progress>'
          : data;
      }
    ")

    # Usa o built-in number renderer e colore por faixas
    salary_js <- htmlwidgets::JS("
      (function(){
        var nfmt = DataTable.render.number('.', ',', 2, 'R$ '); // built-in
        return function(data, type, row, meta){
          var number = nfmt.display(data);
          if (type === 'display') {
            var color = (data < 250000) ? 'red' : (data < 500000 ? 'orange' : 'green');
            return '<span style=\"color:' + color + '\">' + number + '</span>';
          }
          return number;
        };
      })()
    ")

    # Monta opções para df local (client-side). columns = names(df) garante o mapeamento.
    opts <- list(
      lengthChange = TRUE,
      pageLength   = 10,
      lengthMenu = c(10, 25, 50, -1),
      layout = list(
        topStart = list("pageLength"),
        topEnd    = list(
          buttons = list(
            list(
              extend = 'colvis',
              text = "Colunas"
            ),
            list(
              extend = 'collection',
              text = 'Exportar',
              buttons = list(
                list(extend="copyHtml5", text = 'Copiar'),
                list(extend="csvHtml5"),
                list(extend="excelHtml5", title = "Dados exportados"),
                list(extend="pdfHtml5", title = "Dados exportados"),
                list(extend="print", text = "Imprimir",
                     title = "Dados exportados",
                     messageTop = '')
              )
            )
            # list(extend="copyHtml5", text = 'Copiar'),
            # list(extend="csvHtml5"),
            # list(extend="excelHtml5"),
            # list(extend="pdfHtml5"),
            # list(extend="print", text = "Imprimir")
          ),
          search = list(placeholder = "")
        ),
        # top2End = list(
        #   buttons = list(
        #     list(extend="copyHtml5", text = 'Copiar'),
        #     list(extend="csvHtml5"),
        #     list(extend="excelHtml5"),
        #     list(extend="pdfHtml5"),
        #     list(extend="print", text = "Imprimir")
        #   )),
        bottomEnd = list(paging = list(
          firstLast = TRUE,
          previousNext = TRUE,
          numbers = FALSE
        ))
      ),
      columnControl = #list(
        #list(target = 0,
        #     className = 'dtcc-row_no-bottom-border'),
        list(target = 0,
                           content = list("order", "searchDropdown",
                            list(
                               list(extend = 'orderAsc', text = 'Ordem crescente'),
                              list(extend = 'orderDesc', text = 'Ordem decrescente'),
                              'spacer',
                              list(extend = 'colVisDropdown', text = 'Selecionar colunas')
                            )

                           #"searchDropdown"
                           #list(target = 0, content = list("order")),         # 1ª linha do thead
                           #list(target = 1, content = list("searchDropdown"))         # 2ª linha do thead (criada se não existir)
      )),
      # columnDefs = list(
      #   targets = list(3),
      #   columnControl = list('order', list('searchDropdown'))
      # ),
      ordering = list(indicators = FALSE, handler = FALSE), # recomendado pela doc quando usar 'order'
      language = list(
        lengthMenu    = "Mostrar&nbsp; _MENU_",
        lengthLabels = list(
          `10` = "10",
          `25` = "25",
          `50` = "50",
          `-1` = "Todas"
        ),
        search        = "Buscar",
        paginate      = list(
          first = "&laquo;",
          previous="‹",
          `next`="›",
          last= "&raquo;" #"Último"
        ),
        info          = "Mostrando _START_ a _END_ de _TOTAL_ registros",
        infoEmpty     = "Mostrando 0 a 0 de 0 registros",
        infoFiltered  = "(filtrado de _MAX_ registros no total)",
        zeroRecords   = "Nenhum registro encontrado",
        emptyTable    = "Nenhum dado disponível",
        infoPostFix   =    "",
        loadingRecords= "Carregando dados...",
        decimal       = ",",
        thousands     = ".",
        infoThousands = ".",
        buttons = list(
          copyTitle   = "Copiado para a área de transferência",
          copyKeys    = "Pressione <i>Ctrl</i> ou <i>\u2318</i> + <i>C</i> para copiar os dados da tabela para a área de transferência.<br><br>Para cancelar, clique nesta mensagem ou pressione Esc.",
          copySuccess = list(
            `_` = "%d linhas copiadas",
            `1` = "1 linha copiada"
          )
        ),
        columnControl = list(
          buttons = list(
            searchClear = "Limpar pesquisa"
          ),
          colVis = "Visibilidade da coluna",
          colVisDropdown = "Visibilidade da coluna",
          dropdown = "Mostrar mais...",
          list = list(
            all = "Todos",
            empty = "Vazio",
            none = "Nenhum",
            search = "Pesquisar..."
          ),
          orderAddAsc = "Adicionar à ordem crescente",
          orderAddDesc = "Adicionar à ordem decrescente",
          orderAsc = "Ordem crescente",
          orderClear = "Remover ordenação",
          orderDesc = "Ordem decrescente",
          orderRemove = "Remover ordenação",
          reorder = "Reordenar",
          reorderLeft = "Mover para a esquerda",
          reorderRight = "Mover para a direita",
          search = list(
            datetime = list(
              empty = "Vazio",
              equal = "Igual a",
              greater = "Posterior a",
              less = "Anterior a",
              notEmpty = "Não está vazio",
              notEqual = "Diferente de"
            ),
            number = list(
              empty = "Vazio",
              equal = "Igual a",
              greater = "Maior que",
              greaterOrEqual = "Maior ou igual a",
              less = "Menor que",
              lessOrEqual = "Menor ou igual a",
              notEmpty = "Não está vazio",
              notEqual = "Diferente de"
            ),
            text = list(
              contains = "Contém",
              empty = "Vazio",
              ends = "Termina em",
              equal = "Igual a",
              notContains = "Não contém",
              notEmpty = "Não está vazio",
              notEqual = "Diferente de",
              starts = "Começa por"
            )
          ),
          searchClear = "Limpar pesquisa",
          searchDropdown = "Pesquisar"
        ),
        url = 'https://cdn.datatables.net/plug-ins/2.3.3/i18n/pt-BR.json'
      ),
      #select = TRUE
      #select = list(style = "os", items = "row", selector = "td:not(.control)"),
      columns = as.list(setNames(as.list(names(df)), NULL)),  # DataTables v2 aceita [{data:'col'},...]
      columnDefs = list(
        list(targets = which(names(df) == "position") - 1L, render = position_js),
        list(targets = which(names(df) == "office")   - 1L, className = "f32", render = office_js),
        list(targets = which(names(df) == "start_date") - 1L, className = "dt-body-center dt-left"),
        list(targets = which(names(df) == "extn")     - 1L, className = "dt-left", render = extn_js),
        list(targets = which(names(df) == "salary")   - 1L, className = "dt-body-right dt-left", render = salary_js)
      )
    )

    # Importante: passe o df; o dt2.js híbrido lida com linhas objeto/array
    DT2::dt2(
      data        = df,
      options     = dt2_theme(opts, compact = TRUE, striped = TRUE, hover = TRUE),
      server_side = FALSE
      #striped = TRUE, hover = TRUE
    )
  })
}

shinyApp(ui, server)
