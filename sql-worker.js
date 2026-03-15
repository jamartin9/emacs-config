onmessage = (e) => {
    const opt = {"returnValue": "resultRows"};
    const sql ="SELECT REPLACE(name, '.org', '.html') AS name, snippet(site_pages, 1, '<b>','</b>', '', 64) AS snippet FROM site_pages WHERE data MATCH '"+ e.data +"' ORDER BY rank;";
    if (typeof globalThis.sqlite3InitModule === 'undefined') { // load sqlite3
        importScripts('sqlite3.js'); // mjs module?
        globalThis.sqlite3InitModule().then((sqlite3)=> {// shouldnt be possible to get here on the second run so no need to check for poolUtil and unlock
            sqlite3.installOpfsSAHPoolVfs().then((poolUtil)=> { // use opfs for storage
                globalThis.poolUtil = poolUtil; // MAYBE Add weblocks and broadcast api for multi tab with shared workers instead of just vfs pausing
                if (poolUtil.getFileCount() == 0) {
                    console.log("fetching sqlite opfs files");
                    fetch('sqlar.sqlite').then(response => response.arrayBuffer()).then(arrayBuffer => {
                        poolUtil.importDb('/sqlar.sqlite', arrayBuffer); // requires absolute path (lack of transparent naming obscures real name)
                        const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite');
                        const res = db.exec([sql], opt);
                        db.close(); // close and release vfs
                        globalThis.poolUtil.pauseVfs();
                        postMessage(res);
                    });
                } else {
                    console.log("checking existing sqlite opfs files" + poolUtil.getFileNames());
                    fetch('sqlar.sqlite', {method: "HEAD"}).then(response => {
                        console.log("Response headers are: " + response.headers.get("Content-Length"));
                        const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite'); // load existing db to check size against headers
                        console.log("loaded db");
                        const header_size = response.headers.get("Content-Length");
                        const size_sql = "SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size();";
                        const size = db.selectArray(size_sql); // selectArray to not include results in db.exec
                        console.log("Header size is: " + header_size + " DB size is: " + size);
                        if (size == header_size) {
                            console.log("Database is up to date");
                            const res = db.exec([sql], opt);
                            db.close(); // close and release vfs
                            globalThis.poolUtil.pauseVfs();
                            postMessage(res);
                        } else {
                            console.log("Updating database with fetch");
                            db.close(); // close before wiping
                            fetch('sqlar.sqlite').then(response => response.arrayBuffer()).then(arrayBuffer => {
                                poolUtil.wipeFiles().then(_ => {
                                    poolUtil.importDb('/sqlar.sqlite', arrayBuffer);
                                    const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite');
                                    const res = db.exec([sql], opt);
                                    db.close(); // close and release vfs
                                    globalThis.poolUtil.pauseVfs();
                                    postMessage(res);
                                });
                            });
                        }
                    }).catch((error) => {
                        console.log("Failed to fetch HEAD. Using Existing DB.");
                        const db = new poolUtil.OpfsSAHPoolDb('/sqlar.sqlite');
                        const res = db.exec([sql], opt);
                        db.close(); // close and release vfs
                        globalThis.poolUtil.pauseVfs();
                        postMessage(res);
                    });
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
                    globalThis.db = db; // opfs db is no longer shared via globalThis only the global temp db
                    const res = globalThis.db.exec([sql], opt);
                    postMessage(res);// leave db connection open as it is single tab w/o opfs
                });
            });
        });
    }else {
        if (typeof globalThis.poolUtil === 'undefined') {
            console.log("Querying global temp db");
            const res = globalThis.db.exec([sql], opt);// fallback to global temp db from first run; gc will close
            postMessage(res);
        } else {
            globalThis.poolUtil.unpauseVfs().then(() => {// get handle back
                console.log("Querying existing OPFS database");
                const db = new globalThis.poolUtil.OpfsSAHPoolDb('/sqlar.sqlite'); // just load db as first run handles update/cache
                const res = db.exec([sql], opt);
                db.close(); // close to release vfs
                globalThis.poolUtil.pauseVfs();
                postMessage(res);
            }).catch(err => {
                console.log("Failed to unpause OPFS VFS")
            });
        }
    }
};
