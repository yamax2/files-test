package main

import (
    "net/http"
)

func download(w http.ResponseWriter, r *http.Request) {
    fn := r.URL.Query().Get("fn")

    if len(fn) != 0 {
            w.Header().Add("X-Accel-Redirect", "/info/?param=" + fn)
    } else {
            http.Error(w, "ERROR", http.StatusBadRequest)
    }
}

func main() {
    http.HandleFunc("/test", download)
    err := http.ListenAndServe("0.0.0.0:9000", nil)

    if err != nil {
            panic(err)
    }
}
