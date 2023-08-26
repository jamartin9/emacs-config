onmessage = (e) => {
    const opt = {"returnValue": "resultRows"};
    const sql ="SELECT REPLACE(name, '.org', '.html') AS name, snippet(site_pages, 1, '<b>','</b>', '', 64) AS snippet FROM site_pages WHERE data MATCH '"+ e.data +"' ORDER BY rank;";
    if (typeof globalThis.sqlite3InitModule === 'undefined') { // load sqlite3
        importScripts('sqlite3.js');
        globalThis.sqlite3InitModule().then((sqlite3)=> {
            sqlite3.installOpfsSAHPoolVfs().then((poolUtil)=> { // use opfs for storage
                //poolUtil.wipeFiles().await;
                if (poolUtil.getFileCount() == 0) { // TODO add versioning
                    console.log("fetching sqlite opfs files");
                    fetch('sqlar.sqlite').then(response => response.arrayBuffer()).then(arrayBuffer => {
                        //const bytes = new Uint8Array(arrayBuffer);
                        poolUtil.importDb('/sqlar.sqlite', arrayBuffer); // this requires the / for name...(transparent naming?)
                        const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite');
                        globalThis.db = db;
                        const res = db.exec([sql], opt);
                        postMessage(res);
                    });
                } else {
                    console.log("using existing sqlite opfs files" + poolUtil.getFileNames());
                    const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite');
                    globalThis.db = db;
                    const res = db.exec([sql], opt);
                    postMessage(res);
                }
            }).catch((error) => {
                console.log("Failed to use opfs using temp db");
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
                    const res = globalThis.db.exec([sql], opt);
                    postMessage(res);
                });
            });
        });
    }else {
        const res = globalThis.db.exec([sql], opt);
        postMessage(res);
    }
};
