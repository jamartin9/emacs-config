/*
  // MAYBE add service-worker caching with http.vfs splitting
  // MAYBE use 3.43 opfsSAHPoolVfs
  new Worker("sqlite-worker.js"); worker.onmessage = function(msg){}; worker.postMessage(msg); onmessage = function(msg)
  sqlite3.install.OpfsSAHPoolVfs().then((poolUtil) => {}).catch(); db = PoolUtil.OpfsSAHPoolDb('/filename');
  poolUtil.importDb(name, byteArray); poolUtil.getFileNames();
  // ex. html
  <script src="sqlite3.js"></script>
  <article class="panel is-primary">
    <div class="panel-block">
      <input class="input" type="text" placeholder="Search" id="mySearch">
      <button id="mySearchBtn" class="button">&#128269;</button>
    </div>
  </article>
  <dialog id="myModal" class="modal">
    <div class="modal-content">
      <button id="modalClose" class="modal-close is-large" aria-label="close">&times;</button>
      <div id="modalDiv"></div>
    </div>
  </dialog>
  */
document.addEventListener('DOMContentLoaded',() => {
    document.getElementById("modalClose").onclick = function() {
        document.getElementById("myModal").classList.remove("is-active");
        document.getElementById("myModal").close();
    }
    document.getElementById("mySearchBtn").onclick = function() {
        if (typeof globalThis.db === 'undefined') { // load sqlite db
            window.sqlite3InitModule().then((sqlite3)=>{
                const capi = sqlite3.capi,
                      oo = sqlite3.oo1,
                      wasm = sqlite3.wasm;
                const db = new oo.DB();
                fetch('sqlar.sqlite').then(response => response.arrayBuffer()).then(arrayBuffer => {
                    const bytes = new Uint8Array(arrayBuffer);
                    const p = sqlite3.wasm.allocFromTypedArray(bytes);
                    const rc = sqlite3.capi.sqlite3_deserialize(db.pointer, 'main', p, bytes.length, bytes.length,sqlite3.capi.SQLITE_DESERIALIZE_FREEONCLOSE);
                    //db.checkRc(rc);
                    globalThis.db = db;
                    // click with global now defined
                    document.getElementById("mySearchBtn").click();
                });
            });
        } else {
            // write results as links and snippets
            let query = document.getElementById("mySearch").value;
            const res = querydb(query);
            let html = '<table class="table has-background-dark">';
            res.forEach((row) => { html = html + "<tr><td><a href='" +row[0]+"'>"+row[1]+"</a></td></tr>"});
            html = html + "</table>";
            document.getElementById("modalDiv").innerHTML = html;
            document.getElementById("myModal").classList.add("is-active");
            document.getElementById("myModal").showModal();
        }
    }
});
function querydb(query) {
    opt = {"returnValue": "resultRows"};
    const sql ="SELECT REPLACE(name, '.org', '.html') AS name, snippet(site_pages, 1, '<b>','</b>', '', 64) AS snippet FROM site_pages WHERE data MATCH '"+ query +"' ORDER BY rank;";
    return globalThis.db.exec([sql], opt);
  }
