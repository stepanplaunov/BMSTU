package main

import (
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"strings"

	"golang.org/x/net/html"
)

func getAttr(node *html.Node, key string) string {
	for _, attr := range node.Attr {
		if attr.Key == key {
			return attr.Val
		}
	}
	return ""
}

func isOK(g string) bool {
	f := g != "" && g[0] == uint8('/')
	return f && !(strings.Contains(g, "https") || strings.Contains(g, "http")) && g != "/" && !contains(g)
}

func contains(g string) bool {
	for i := range hrefs {
		if hrefs[i] == g {
			return true
		}
	}
	return false
}

var hrefs []string

func search(node *html.Node) {
	for c := node.FirstChild; c != nil; c = c.NextSibling {
		g := getAttr(c, "href")
		if isOK(g) {
			hrefs = append(hrefs, g)
		}
	}
	for c := node.FirstChild; c != nil; c = c.NextSibling {
		search(c)
	}

}

func download(path string) *html.Node {
	if response, err := http.Get(path); err != nil {
		log.Fatal("request to", path, "failed\n", "error: ", err)
	} else {
		defer response.Body.Close()
		if response.StatusCode == http.StatusOK {
			if doc, err := html.Parse(response.Body); err != nil {
				log.Fatal("invalid HTML form", "error: ", err)
			} else {
				return doc
			}
		}
	}
	return nil
}

func main() {
	http.HandleFunc("/", func(writer http.ResponseWriter, request *http.Request) {
		http.ServeFile(writer, request, "main.html")
	})

	http.HandleFunc("/AuthRes", func(writer http.ResponseWriter, request *http.Request) {
		path := request.FormValue("path")
		hrefs = append(hrefs, "/home")
		search(download(path))
		for i := range hrefs {
			var (
				ref string
				url = path
			)
			ref = hrefs[i]
			if ref != "/home" {
				url += ref
			}
			http.HandleFunc(ref, func(writer http.ResponseWriter, request *http.Request) {
				resp, err := http.Get(url)
				if err != nil {
					log.Fatal(err)
				}
				defer resp.Body.Close()
				data, err := ioutil.ReadAll(resp.Body)
				if err != nil {
					log.Fatal(err)
				}
				res := string(data)
				t := template.New(ref)
				_, _ = t.Parse(res)
				_ = t.Execute(writer, res)
			})
		}
		http.Redirect(writer, request, "/home", http.StatusSeeOther)
	})

	err := http.ListenAndServe("localhost:9000", nil)
	if err != nil {
		log.Fatal(err)
	}
}
