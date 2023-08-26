/* Requires sqlite3.js, sqlite3.wasm and sql-worker.js(my worker wrapper)
    // MAYBE add service-worker caching with http.vfs splitting
    // MAYBE use opfs vfs with sync support (multiple tabs)
    // example page:
    <script src="sqlite3.js"></script>
    <script src="sqlite-query.js"></script>

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
        if (typeof globalThis.w === 'undefined') { // load sqlite worker
            console.log("creating worker");
                const workerArgs = [];
                workerArgs.push("sql-worker.js");
                const w = new Worker(...workerArgs);
                w.onmessage = (msg) => { // write results as table rows and links
                    let html = '<table class="table has-background-dark">';
                    msg.data.forEach((row) => { html = html + "<tr><td><a href='" +row[0]+"'>"+row[1]+"</a></td></tr>"});
                    html = html + "</table>";
                    document.getElementById("modalDiv").innerHTML = html;
                    document.getElementById("myModal").classList.add("is-active");
                    document.getElementById("myModal").showModal();
                };
                globalThis.w = w; // query worker
                let query = document.getElementById("mySearch").value;
                globalThis.w.postMessage(query);
        } else {
            let query = document.getElementById("mySearch").value;
            globalThis.w.postMessage(query);
        }
    }
});
