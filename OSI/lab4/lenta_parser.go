package main

import (
	"fmt"
	"golang.org/x/net/html"
	"log"
	"net/http"
)

type Item struct {
	Ref, Time, Title string
}

func getChildren(node *html.Node) []*html.Node {
	var children []*html.Node
	for c := node.FirstChild; c != nil; c = c.NextSibling{
		children = append(children,c)
	}
	return children
}

func getAttr(node *html.Node,key string) string{
	for _, attr := range node.Attr {
		if attr.Key == key {
			return attr.Val
		}
	}
	return ""
}

func isText(node *html.Node) bool {
	return node != nil && node.Type == html.TextNode

}

func isElem(node *html.Node, tag string) bool {
	return node != nil && node.Type == html.ElementNode && node.Data == tag
}

func isSection(node *html.Node, class string) bool {
	return isElem(node, "section") && getAttr(node, "class") == class
}

func isDiv(node *html.Node, class string) bool {
	return isElem(node, "div") && getAttr(node, "class") == class
}

func readItem(item *html.Node) *Item {
	if a := item.FirstChild; isElem(a, "a") {
		b := a.FirstChild.NextSibling
		return &Item{
			Ref:   getAttr(a, "href"),
			Time:  getAttr(b, "title"),
			Title: b.Data,
		}

	}
	return nil
}

func downloadNews() []*Item  {
	if response,err := http.Get("http://lenta.ru"); err != nil {
		log.Println("request to lenta.ru failed", "error",err)
	} else {
		defer response.Body.Close()
		status := response.StatusCode
		if status == http.StatusOK {
			if doc,err := html.Parse(response.Body); err != nil {
				log.Println("invalid HTML from lenta.ru", "err", err)
			} else {
				items := search(doc)
				return items
			}
		}
	}
	return nil
}

func search(node *html.Node) []*Item {
	if isSection(node,"row b-top7-for-main js-top-seven"){
		var items []*Item
		node = node.FirstChild
		node = node.NextSibling
		for c:= node.FirstChild; c != nil; c = c.NextSibling {
			//b:= c.FirstChild

			if isDiv(c, "item") {
				if item := readItem(c); item != nil{
					items = append(items, item)
				}
			}
		}

		return items
	}
	for c := node.FirstChild; c != nil; c = c.NextSibling {
		if items := search(c);items != nil {
			return items
		}
	}
	return nil
}

func main() {
	items := downloadNews()
	for _,k := range items {
		//fmt.Println(k.Time)
		fmt.Println(k.Title)
		//fmt.Println(k.Ref)
	}
}