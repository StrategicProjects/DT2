
/*! dt2.js — patched with hybrid accessors (arrays OR objects)
 *  Works for client-side (HTMLWidgets.dataframeToD3) & server-side (ajax)
 *  v0.2.0-aurora
 */
(function () {
  // --- util: wait until jQuery & DataTables are ready
  function waitForDeps(cb, needExts, tries, delay) {
    tries = (typeof tries === "number" ? tries : 200);
    delay = (typeof delay === "number" ? delay : 25);
    (function loop(t) {
      var jqOK = (typeof window.jQuery === "function");
      var dtOK = (typeof window.DataTable === "function");
      if (jqOK && dtOK) return cb();
      if (t <= 0) {
        console.error("[DT2] Dependencies did not load in time.",
          "jQuery:", typeof window.jQuery, "DataTable:", typeof window.DataTable);
        return;
      }
      setTimeout(function(){ loop(t - 1); }, delay);
    })(tries);
  }

  // --- util: header builder (optional, cosmetic)
  function buildHeader(tbl, columns) {
    if (!columns || !columns.length) return;
    const thead = document.createElement('thead');
    const tr = document.createElement('tr');
    columns.forEach(function (c) {
      const th = document.createElement('th');
      th.textContent = c;
      tr.appendChild(th);
    });
    thead.appendChild(tr);
    tbl.appendChild(thead);
  }

  // --- util: guess names from a sample row
  function inferNamesFromRow(row) {
    if (!row) return null;
    if (Array.isArray(row)) return row.map(function (_, i) { return "V" + (i + 1); });
    if (typeof row === "object") return Object.keys(row);
    return null;
  }

  // --- util: simple accessor by key (legacy; used only for dotted keys fallback)
  function accessorForKey(key) {
    return function (row) { return row ? row[key] : undefined; };
  }

  // --- PATCH: hybrid accessor & column factory (array OR object rows)
  function hybridAccessor(name, idx) {
    return function (row) {
      if (row == null) return undefined;
      if (Array.isArray(row)) return row[idx];
      if (typeof row === "object") return row[name];
      return undefined;
    };
  }

  function columnsFromNamesHybrid(colNames, sampleRow) {
    return (colNames || []).map(function (nm, i) {
      var useAccessor = (typeof nm === "string" && nm.indexOf(".") >= 0);
      var dataProp;
      if (useAccessor) {
        var flatAccessor = function (row) {
          if (row == null) return undefined;
          if (Array.isArray(row)) return row[i];
          return row[nm]; // keep shallow dotted behavior as before
        };
        dataProp = flatAccessor;
      } else {
        dataProp = hybridAccessor(nm, i);
      }
      return { data: dataProp, title: nm, defaultContent: "" };
    });
  }

  // --- legacy helper (kept but now returns hybrid accessors when given strings)
  function normalizeColumns(cols) {
    if (Array.isArray(cols) && cols.length && typeof cols[0] === "string") {
      return cols.map(function(nm, i){ return { data: hybridAccessor(nm, i), title: nm, defaultContent: "" }; });
    }
    return cols;
  }

  // --- if data comes as objects, keep previous behavior
  function columnsForData(jsData, providedNames) {
    const row0 = (jsData && jsData.length) ? jsData[0] : null;
    const rowsAreObjects = row0 && !Array.isArray(row0) && typeof row0 === "object";
    let colNames = Array.isArray(providedNames) && providedNames.length
      ? providedNames : (inferNamesFromRow(row0) || []);
    if (!rowsAreObjects) {
      // arrays: create by index with titles from colNames
      return colNames.map(function (name, i) {
        return { data: i, title: name, defaultContent: "" };
      });
    }
    // objects: use hybrid so it still works if data later flips to arrays
    return columnsFromNamesHybrid(colNames, row0);
  }

  HTMLWidgets.widget({
    name: 'dt2',
    type: 'output',
    factory: function (el, width, height) {
      let table;

      function initTable(x) {
        if (table) { try { table.destroy(); } catch (e) {} table = null; }
        el.innerHTML = '';

        const tbl = document.createElement('table');
        const theme = (x.options && x.options.dt2_theme) || {};
        const isBS5 = (theme.bs === 'bootstrap5');

        // Apply font_scale BEFORE DataTable init so the <select> for
        // page length renders at the correct size from the start.
        // (Changing font-size after init causes the select to show blank.)
        if (theme.font_scale) {
          el.style.fontSize = (theme.font_scale * 100) + '%';
        }

        // Build table classes based on styling mode
        let classes = [];
        if (theme.class) {
          // Full CSS class override from R
          classes = theme.class.split(/\s+/);
        } else if (isBS5) {
          // Bootstrap 5 classes
          classes.push('table');
          if (theme.striped) classes.push('table-striped');
          if (theme.hover)   classes.push('table-hover');
          if (theme.compact) classes.push('table-sm');
        } else {
          // DataTables core classes
          classes.push('display');
          if (theme.compact) classes.push('compact');
        }
        tbl.className = classes.join(' ');
        tbl.style.width = '100%';
        el.appendChild(tbl);

        const isServer = !!(x.server_side || x.serverSide);

        // data (client-side)
        let jsData = null;
        if (!isServer) {
          jsData = HTMLWidgets.dataframeToD3(x.data || []);
        }

        // header (optional)
        let providedNames = Array.isArray(x.columns) && x.columns.length ? x.columns : null;
        let headerNames = providedNames;
        if (!headerNames && jsData && jsData.length) headerNames = inferNamesFromRow(jsData[0]);
        if (isServer && providedNames) headerNames = providedNames;
        if (headerNames) buildHeader(tbl, headerNames);

        // options
        const opts = Object.assign({}, x.options || {});
        // wipe legacy aliases that can conflict
        delete opts.aoColumns; delete opts.aoColumnDefs; delete opts.oLanguage;

        // Remove DT2-specific keys that DataTables doesn't understand
        var buttonClass = (opts.dt2_theme && opts.dt2_theme.button_class) || null;
        delete opts.dt2_theme;
        delete opts.dt2_buttons_target;

        // Set compact button defaults for BS5 (btn-sm + outline)
        if (typeof DataTable.Buttons !== 'undefined' && DataTable.Buttons.defaults) {
          var btnCls = buttonClass || 'btn btn-sm btn-outline-secondary';
          try {
            DataTable.Buttons.defaults.dom.button.className = btnCls;
          } catch(e) {}
        }

        // Default autoWidth to false — prevents DataTables from calculating
        // fixed pixel widths on <col> elements, which would prevent the
        // table from stretching to fill its container.
        // User can set autoWidth = TRUE in R options to override.
        if (typeof opts.autoWidth === 'undefined') {
          opts.autoWidth = false;
        }

        // Ensure lengthMenu is always set — prevents empty "entries per page"
        // select when pageLength is set to a non-standard value.
        if (!opts.lengthMenu) {
          var pl = opts.pageLength || 10;
          var menu = [10, 25, 50, 100];
          if (menu.indexOf(pl) === -1) {
            menu.push(pl);
            menu.sort(function(a, b) { return a - b; });
          }
          opts.lengthMenu = menu;
        }

        // Convert legacy 2D array lengthMenu to DT 2.x format
        // Old: [[10,25,50,-1],["10","25","50","All"]]
        // New: [10, 25, 50, {label:"All", value:-1}]
        if (Array.isArray(opts.lengthMenu) && opts.lengthMenu.length === 2 &&
            Array.isArray(opts.lengthMenu[0]) && Array.isArray(opts.lengthMenu[1])) {
          var vals = opts.lengthMenu[0];
          var labs = opts.lengthMenu[1];
          var converted = [];
          for (var mi = 0; mi < vals.length; mi++) {
            if (String(vals[mi]) === String(labs[mi])) {
              converted.push(vals[mi]);
            } else {
              converted.push({ label: labs[mi], value: vals[mi] });
            }
          }
          opts.lengthMenu = converted;
        }

        // Convert legacy dom="Bfrtip" to layout (DT2.x modern API)
        if (opts.dom && typeof opts.dom === 'string' && opts.dom.indexOf('B') >= 0) {
          // If user used dom with B but no layout, create a layout equivalent
          if (!opts.layout) {
            opts.layout = { topEnd: 'buttons' };
          }
          delete opts.dom; // remove deprecated dom
        }

        if (x.options && typeof x.options.deferRender !== 'undefined') {
          opts.deferRender = !!x.options.deferRender;
        }

        if (x.options && typeof x.options.responsive !== 'undefined') {
          // Keep as-is if object (e.g. {details: false}), coerce only booleans
          opts.responsive = (typeof x.options.responsive === 'object')
            ? x.options.responsive
            : !!x.options.responsive;
        }

        // global defaultContent fallback
        opts.columnDefs = (opts.columnDefs || []);
        opts.columnDefs.push({ targets: "_all", defaultContent: "", sDefaultContent: "" });

        if (!isServer) {
          // --- CLIENT-SIDE ---
          if (Array.isArray(opts.columns) && opts.columns.length && typeof opts.columns[0] === "string") {
            opts.columns = columnsFromNamesHybrid(opts.columns, (jsData && jsData[0]));
          } else if (!opts.columns) {
            var row0 = (jsData && jsData.length) ? jsData[0] : null;
            var colNames = (Array.isArray(providedNames) && providedNames.length)
              ? providedNames
              : (inferNamesFromRow(row0) || []);
            opts.columns = Array.isArray(row0)
              ? colNames.map(function(nm, i){ return { data: i, title: nm, defaultContent: "" }; })
              : columnsFromNamesHybrid(colNames, row0);
          }
          opts.data = jsData || [];
        } else {
          // --- SERVER-SIDE ---
          if (Array.isArray(opts.columns) && opts.columns.length && typeof opts.columns[0] === "string") {
            opts.columns = columnsFromNamesHybrid(opts.columns, null);
          } else if (!opts.columns && Array.isArray(providedNames) && providedNames.length) {
            opts.columns = columnsFromNamesHybrid(providedNames, null);
          }
          opts.serverSide = true;

          // Shiny fallback for server-side processing (if no ajax provided)
          if (!opts.ajax && typeof window.Shiny === "object") {
            var respHandlerName = el.id + "_server_resp";
            var pending = null; // latest callback
            if (!el._dt2_ssp_bound) {
              el._dt2_ssp_bound = true;
              Shiny.addCustomMessageHandler(respHandlerName, function(payload){
                try {
                  if (typeof pending === "function") pending(payload);
                  pending = null;
                } catch(e){ console.error("[DT2] SSP resp handler:", e); }
              });
            }
            // DataTables expects a function signature (data, callback, settings)
            opts.ajax = function (request, callback, settings) {
              try {
                // stash callback until server responds
                pending = callback;
                // encode request as queryString
                var qs = Object.keys(request).map(function(k){
                  var v = request[k];
                  if (Array.isArray(v)) {
                    return v.map(function(vi){ return encodeURIComponent(k+'[]') + '=' + encodeURIComponent(vi); }).join('&');
                  } else if (v && typeof v === 'object') {
                    // flatten 1-level objects
                    return Object.keys(v).map(function(sub){
                      return encodeURIComponent(k+'['+sub+']') + '=' + encodeURIComponent(v[sub]);
                    }).join('&');
                  }
                  return encodeURIComponent(k) + '=' + encodeURIComponent(v);
                }).join('&');
                // trigger server request
                Shiny.setInputValue(el.id + "_server_req", { queryString: qs }, {priority:"event"});
              } catch(e){
                console.error("[DT2] SSP ajax error:", e);
                callback({ draw: 0, recordsTotal: 0, recordsFiltered: 0, data: [] });
              }
            };
          }

          // only define ajax if R-side didn't provide a full opts.ajax already
          if (!opts.ajax && x.server_ajax) {
            // if R passed a URL string, wrap with default DataTables expectation {data:...}
            if (typeof x.server_ajax === "string") {
              opts.ajax = {
                url: x.server_ajax,
                type: "POST"
                // default dataSrc is "data"; customize here if your API differs
              };
            } else {
              // assume it's already a valid object
              opts.ajax = x.server_ajax;
            }
          }
        }

        if (typeof window.DataTable !== "function") {
          console.error("[DT2] DataTables unavailable; check jQuery + DataTables scripts.");
          return;
        }

        try {
          // moment locale (optional)
          if (x.options && x.options._momentLocale) {
            if (window.moment && typeof moment.locale === 'function') {
              moment.locale(x.options._momentLocale);
            }
          }
          // createdRow passthrough (htmlwidgets::JS from R)
          if (x.options && x.options.createdRow) {
            opts.createdRow = x.options.createdRow;
          }

          // debug sample (client)
          if (!isServer && jsData && jsData.length) {
            console.log("[DT2] sample row is", Array.isArray(jsData[0]) ? "Array" : typeof jsData[0], jsData[0]);
          }

          table = new DataTable(tbl, opts);

          // --- expor a API por vários caminhos confiáveis
try {
  // 1) container do htmlwidget
  el._dt2 = table;

  // 2) própria <table>
  tbl._dt2 = table;

  // 3) container do DataTables (wrapper)
  var wrap = table.table().container();
  if (wrap) wrap._dt2 = table;

  // 4) registrar na ponte jQuery (para $('#id').DataTable() / .data('dt-api'))
  if (window.jQuery && jQuery.fn) {
    jQuery(tbl).data('DataTable', table).data('dt-api', table);
    if (wrap) jQuery(wrap).data('DataTable', table).data('dt-api', table);
  }
} catch(e) { /* noop */ }

          // Post-init: fix for page-length <select> sometimes appearing blank.
          // When font_scale shrinks the container, the browser may render the
          // select before its intrinsic size is recalculated.  Force a repaint.
          try {
            var lenSel = el.querySelector('.dt-length select');
            if (lenSel) {
              // Trigger a repaint by toggling display
              lenSel.style.display = 'none';
              lenSel.offsetHeight; // force layout
              lenSel.style.display = '';
              // Ensure the current value is reflected
              if (opts.pageLength && lenSel.value != opts.pageLength) {
                lenSel.value = opts.pageLength;
              }
            }
          } catch(e2) { /* noop */ }

        } catch (e) {
          console.error("[DT2] Failed to instantiate DataTable:", e);
          try {
            console.log("[DT2] Sample record:", (jsData && jsData[0]) || "(server-side)");
            console.log("[DT2] opts.columns:", opts.columns);
          } catch(_) {}
          return;
        }

        // expose for debugging
  //      el._dt2 = table;

        // --- push state to Shiny input$id_state
        function pushState(reason) {
          if (!window.Shiny || !table) return;
          var selIdx = [];
          try { selIdx = table.rows({ selected:true }).indexes().toArray(); } catch(e){}
          var page = table.page.info();
          var state = table.state && table.state();
          Shiny.setInputValue(el.id + "_state", {
            reason: reason,
            order: table.order(),
            search: table.search(),
            page: page,
            selected: selIdx,
            state: state
          }, {priority:"event"});
        }

        table.off('.dt2state');
        table.on('init.dt.dt2state draw.dt.dt2state order.dt.dt2state search.dt.dt2state page.dt.dt2state select.dt.dt2state deselect.dt.dt2state',
          function(e){ pushState(e.type.split('.')[0]); });

        // --- Shiny proxy (R -> JS)
        if (window.Shiny && !el._proxyBound) {
          el._proxyBound = true;
          Shiny.addCustomMessageHandler(el.id + "_proxy", function(msg){
            if(!table) return;
            switch(msg.cmd || msg.type){
              case "replaceData":
                try { table.clear(); table.rows.add(msg.data || []); table.draw(false); }
                catch(e){ console.error("[DT2] replaceData:", e); }
                break;
              case "draw": table.draw(false); break;
              case "order": {
                var spec = (msg.args && msg.args[0]) ? msg.args[0] : [];
                var arr = spec.map(function(x){
                  var col = x[0], dir = x[1];
                  if (typeof col === 'string') {
                    var idx = table.columns().indexes().toArray().find(function(i){
                      var name = table.column(i).header().textContent.trim();
                      return name === col;
                    });
                    return [ (idx!=null?idx:0), dir ];
                  }
                  return [ (parseInt(col,10)-1), dir ];
                });
                table.order(arr).draw();
                break;
              }
              case "search": table.search(msg.args[0], msg.args[1], msg.args[2], msg.args[3]).draw(); break;
              case "page":
                if (msg.args[0] === 'number') table.page(parseInt(msg.args[1],10)).draw(false);
                else table.page(msg.args[0]).draw(false);
                break;
              case "selectRows":
                try {
                  if (msg.args[1]) table.rows().deselect();
                  var zero = (msg.args[0] || []).map(function(i){ return i-1; });
                  table.rows(zero).select();
                } catch(e){}
                break;
            }
          });
        }

        // --- delegated inputs (row-checkbox / row-button)
        if (window.jQuery && window.Shiny) {
          var $tbl = window.jQuery(tbl);
          $tbl.off('.dt2inputs');
          $tbl.on('change.dt2inputs', 'input.dt2-row-checkbox', function(){
            var $tr = window.jQuery(this).closest('tr');
            var row = table.row($tr).index();
            Shiny.setInputValue(el.id + "_row_check", { row: row+1, value: this.checked }, {priority:"event"});
          });
          $tbl.on('click.dt2inputs', 'button.dt2-row-button', function(){
            var $tr = window.jQuery(this).closest('tr');
            var row = table.row($tr).index();
            Shiny.setInputValue(el.id + "_row_button", { row: row+1, id: this.id }, {priority:"event"});
          });
        }
      }

      return {
        renderValue: function (x) {
          // support both names coming from R
          x.serverSide = !!(x.server_side || x.serverSide);
          waitForDeps(function(){ initTable(x); });
        },
        resize: function () {
          if (table && table.columns && table.columns.adjust) {
            try { table.columns.adjust(); } catch (e) {}
          }
        }
      };
    }
  });
})();
