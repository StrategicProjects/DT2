#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# DT2 Library Downloader
# =============================================================================
# Update the version variables below, then run:
#   bash tools/get-dt2-libs.sh
#
# All files are saved under inst/htmlwidgets/lib/
# =============================================================================

# ---- VERSION CONFIGURATION (edit these to update) ----
JQUERY_VER="3.7.0"
MOMENT_VER="2.29.4"
JSZIP_VER="3.10.1"
PDFMAKE_VER="0.2.7"
BS_VER="5.3.8"

DT_VER="2.3.4"         # DataTables core
BTN_VER="3.2.5"        # Buttons
CR_VER="2.1.1"         # ColReorder
CC_VER="1.1.0"         # ColumnControl
DTM_VER="1.6.0"        # DateTime
FC_VER="5.0.5"         # FixedColumns
FH_VER="4.0.3"         # FixedHeader
KT_VER="2.12.1"        # KeyTable
RS_VER="3.0.6"         # Responsive
RG_VER="1.6.0"         # RowGroup
RR_VER="1.5.0"         # RowReorder
SCR_VER="2.4.3"        # Scroller
SB_VER="1.8.4"         # SearchBuilder
SP_VER="2.3.5"         # SearchPanes
SEL_VER="3.1.0"        # Select
SR_VER="1.4.2"         # StateRestore
# ---- END VERSION CONFIGURATION ----

ROOT="inst/htmlwidgets/lib"
mkdir -p "$ROOT"

fetch() {
  local out="$1"
  local url="$2"
  mkdir -p "$(dirname "$out")"
  echo "  -> $out"
  curl -fsSL "$url" -o "$out"
}

echo "=== DT2 Library Download ==="
echo "Target: $ROOT"
echo ""

# --- jQuery ---
echo "[jQuery $JQUERY_VER]"
fetch "$ROOT/jquery/$JQUERY_VER/jquery.min.js" \
  "https://code.jquery.com/jquery-${JQUERY_VER}.min.js"

# --- Moment.js ---
echo "[Moment $MOMENT_VER]"
fetch "$ROOT/moment/$MOMENT_VER/moment.min.js" \
  "https://cdnjs.cloudflare.com/ajax/libs/moment.js/$MOMENT_VER/moment.min.js"

# --- JSZip ---
echo "[JSZip $JSZIP_VER]"
fetch "$ROOT/jszip/$JSZIP_VER/jszip.min.js" \
  "https://cdnjs.cloudflare.com/ajax/libs/jszip/$JSZIP_VER/jszip.min.js"

# --- pdfmake ---
# NOTE: cdnjs only hosts up to 0.2.12. jsdelivr mirrors npm and has all versions.
echo "[pdfmake $PDFMAKE_VER]"
fetch "$ROOT/pdfmake/$PDFMAKE_VER/pdfmake.min.js" \
  "https://cdn.jsdelivr.net/npm/pdfmake@$PDFMAKE_VER/build/pdfmake.min.js"
fetch "$ROOT/pdfmake/$PDFMAKE_VER/vfs_fonts.js" \
  "https://cdn.jsdelivr.net/npm/pdfmake@$PDFMAKE_VER/build/vfs_fonts.js"

# --- Bootstrap 5 ---
echo "[Bootstrap $BS_VER]"
fetch "$ROOT/bootstrap/$BS_VER/js/bootstrap.bundle.min.js" \
  "https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/$BS_VER/js/bootstrap.bundle.min.js"
fetch "$ROOT/bootstrap/$BS_VER/css/bootstrap.min.css" \
  "https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/$BS_VER/css/bootstrap.min.css"

# --- DataTables core ---
echo "[DataTables $DT_VER]"
fetch "$ROOT/datatables/$DT_VER/js/dataTables.min.js" \
  "https://cdn.datatables.net/$DT_VER/js/dataTables.min.js"
fetch "$ROOT/datatables/$DT_VER/css/dataTables.dataTables.min.css" \
  "https://cdn.datatables.net/$DT_VER/css/dataTables.dataTables.min.css"
fetch "$ROOT/datatables/$DT_VER/js/dataTables.bootstrap5.min.js" \
  "https://cdn.datatables.net/$DT_VER/js/dataTables.bootstrap5.min.js"
fetch "$ROOT/datatables/$DT_VER/css/dataTables.bootstrap5.min.css" \
  "https://cdn.datatables.net/$DT_VER/css/dataTables.bootstrap5.min.css"

# ---- Helper for extensions ----
# Usage: dl_ext "name" "VER" "dir" "js_files" "css_files"
# js_files and css_files are space-separated
dl_ext() {
  local name="$1" ver="$2" dir="$3"
  shift 3
  local js_files="$1" css_files="$2"
  echo "[$name $ver]"
  for f in $js_files; do
    fetch "$ROOT/$dir/$ver/$f" "https://cdn.datatables.net/$dir/$ver/$f"
  done
  for f in $css_files; do
    fetch "$ROOT/$dir/$ver/$f" "https://cdn.datatables.net/$dir/$ver/$f"
  done
}

# --- Buttons ---
echo "[Buttons $BTN_VER]"
for f in js/dataTables.buttons.min.js js/buttons.colVis.min.js js/buttons.html5.min.js js/buttons.print.min.js js/buttons.bootstrap5.min.js; do
  fetch "$ROOT/buttons/$BTN_VER/$f" "https://cdn.datatables.net/buttons/$BTN_VER/$f"
done
for f in css/buttons.dataTables.min.css css/buttons.bootstrap5.min.css; do
  fetch "$ROOT/buttons/$BTN_VER/$f" "https://cdn.datatables.net/buttons/$BTN_VER/$f"
done

# --- ColReorder ---
dl_ext "ColReorder" "$CR_VER" "colreorder" \
  "js/dataTables.colReorder.min.js" \
  "css/colReorder.dataTables.min.css css/colReorder.bootstrap5.min.css"

# --- ColumnControl ---
echo "[ColumnControl $CC_VER]"
for f in js/dataTables.columnControl.min.js js/columnControl.bootstrap5.min.js; do
  fetch "$ROOT/columncontrol/$CC_VER/$f" "https://cdn.datatables.net/columncontrol/$CC_VER/$f"
done
for f in css/columnControl.dataTables.min.css css/columnControl.bootstrap5.min.css; do
  fetch "$ROOT/columncontrol/$CC_VER/$f" "https://cdn.datatables.net/columncontrol/$CC_VER/$f"
done

# --- DateTime ---
dl_ext "DateTime" "$DTM_VER" "datetime" \
  "js/dataTables.dateTime.min.js" \
  "css/dataTables.dateTime.min.css"

# --- FixedColumns ---
dl_ext "FixedColumns" "$FC_VER" "fixedcolumns" \
  "js/dataTables.fixedColumns.min.js" \
  "css/fixedColumns.dataTables.min.css css/fixedColumns.bootstrap5.min.css"

# --- FixedHeader ---
dl_ext "FixedHeader" "$FH_VER" "fixedheader" \
  "js/dataTables.fixedHeader.min.js" \
  "css/fixedHeader.dataTables.min.css css/fixedHeader.bootstrap5.min.css"

# --- KeyTable ---
dl_ext "KeyTable" "$KT_VER" "keytable" \
  "js/dataTables.keyTable.min.js" \
  "css/keyTable.dataTables.min.css css/keyTable.bootstrap5.min.css"

# --- Responsive ---
echo "[Responsive $RS_VER]"
for f in js/dataTables.responsive.min.js js/responsive.bootstrap5.js; do
  fetch "$ROOT/responsive/$RS_VER/$f" "https://cdn.datatables.net/responsive/$RS_VER/$f"
done
for f in css/responsive.dataTables.min.css css/responsive.bootstrap5.min.css; do
  fetch "$ROOT/responsive/$RS_VER/$f" "https://cdn.datatables.net/responsive/$RS_VER/$f"
done

# --- RowGroup ---
dl_ext "RowGroup" "$RG_VER" "rowgroup" \
  "js/dataTables.rowGroup.min.js" \
  "css/rowGroup.dataTables.min.css css/rowGroup.bootstrap5.min.css"

# --- RowReorder ---
dl_ext "RowReorder" "$RR_VER" "rowreorder" \
  "js/dataTables.rowReorder.min.js" \
  "css/rowReorder.dataTables.min.css css/rowReorder.bootstrap5.min.css"

# --- Scroller ---
dl_ext "Scroller" "$SCR_VER" "scroller" \
  "js/dataTables.scroller.min.js" \
  "css/scroller.dataTables.min.css css/scroller.bootstrap5.min.css"

# --- SearchBuilder ---
echo "[SearchBuilder $SB_VER]"
for f in js/dataTables.searchBuilder.min.js js/searchBuilder.bootstrap5.min.js; do
  fetch "$ROOT/searchbuilder/$SB_VER/$f" "https://cdn.datatables.net/searchbuilder/$SB_VER/$f"
done
for f in css/searchBuilder.dataTables.min.css css/searchBuilder.bootstrap5.min.css; do
  fetch "$ROOT/searchbuilder/$SB_VER/$f" "https://cdn.datatables.net/searchbuilder/$SB_VER/$f"
done

# --- SearchPanes ---
echo "[SearchPanes $SP_VER]"
for f in js/dataTables.searchPanes.min.js js/searchPanes.bootstrap5.min.js; do
  fetch "$ROOT/searchpanes/$SP_VER/$f" "https://cdn.datatables.net/searchpanes/$SP_VER/$f"
done
for f in css/searchPanes.dataTables.min.css css/searchPanes.bootstrap5.min.css; do
  fetch "$ROOT/searchpanes/$SP_VER/$f" "https://cdn.datatables.net/searchpanes/$SP_VER/$f"
done

# --- Select ---
dl_ext "Select" "$SEL_VER" "select" \
  "js/dataTables.select.min.js" \
  "css/select.dataTables.min.css css/select.bootstrap5.min.css"

# --- StateRestore ---
echo "[StateRestore $SR_VER]"
for f in js/dataTables.stateRestore.min.js js/stateRestore.bootstrap5.min.js; do
  fetch "$ROOT/staterestore/$SR_VER/$f" "https://cdn.datatables.net/staterestore/$SR_VER/$f"
done
for f in css/stateRestore.dataTables.min.css css/stateRestore.bootstrap5.min.css; do
  fetch "$ROOT/staterestore/$SR_VER/$f" "https://cdn.datatables.net/staterestore/$SR_VER/$f"
done

echo ""
echo "=== Done! ==="
echo ""
echo "Installed versions:"
echo "  DataTables   $DT_VER"
echo "  jQuery       $JQUERY_VER"
echo "  Bootstrap    $BS_VER"
echo "  Buttons      $BTN_VER"
echo "  ColReorder   $CR_VER"
echo "  ColumnControl $CC_VER"
echo "  DateTime     $DTM_VER"
echo "  FixedColumns $FC_VER"
echo "  FixedHeader  $FH_VER"
echo "  KeyTable     $KT_VER"
echo "  Responsive   $RS_VER"
echo "  RowGroup     $RG_VER"
echo "  RowReorder   $RR_VER"
echo "  Scroller     $SCR_VER"
echo "  SearchBuilder $SB_VER"
echo "  SearchPanes  $SP_VER"
echo "  Select       $SEL_VER"
echo "  StateRestore $SR_VER"
echo ""
echo "Remember to update version strings in R/dt2_extensions.R and R/dt2_deps.R"
echo "if you changed any version above."
