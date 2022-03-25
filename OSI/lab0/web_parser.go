package main

import ("strings"
"fmt" // пакет для форматированного ввода вывода

"net/http" // пакет для поддержки HTTP протокола

//"strings" // пакет для работы с UTF-8 строками

"log" // пакет для логирования
"sort"

"github.com/RealJK/rss-parser-go"

)

func countItem(path string) int {
	rssObject, _ := rss.ParseRSS(path)
	return len(rssObject.Channel.Items)
}

func HomeRouterHandler(w http.ResponseWriter, r *http.Request) {

	r.ParseForm() //анализ аргументов,

	w.Header().Set("Content-Type", "text/html;charset=utf-8")
	arr := []string{"http://www.rssboard.org/files/sample-rss-2.xml", "http://blagnews.ru/rss_vk.xml",
		"https://lenta.ru/rss"}
	for i := range arr {
		fmt.Fprintf(w, "<div>В <a href='%s'>%s</a> количество итемов равно: %d</div>", arr[i], strings.Split(arr[i], "/")[2], countItem(arr[i]))
	}

	rssObject, err := rss.ParseRSS("http://lenta.ru/rss")
	fmt.Fprintf(w, "<style type='text/css'>" +
		"img  {" +
		"height:300;" +
		"margin-left: auto;" +
		"margin-right: auto;" +
		"display: block;" +
		"width:400" +
		"}" +
		"</style>")
	fmt.Fprintf(w, "url is") // отправляем данные на клиентскую сторону

	fmt.Fprintf(w, r.URL.Path)
	if err != nil {

		sort.Slice(rssObject.Channel.Items, func(i, j int) bool {
			return rssObject.Channel.Items[i].PubDate > rssObject.Channel.Items[j].PubDate
		})

		for v := range rssObject.Channel.Items {
			item := rssObject.Channel.Items[v]
			fmt.Fprintf(w,"<div><a href='%s'>%s</a></div>", item.Link, item.Title)
			fmt.Fprintf(w,"<div>%s</div>", item.PubDate)
			fmt.Fprintf(w,"<div>%s</div>", item.Description)
		}
	}

	//for k, v := range r.Form {
	//
	//	fmt.Println("key: ", k)
	//
	//	fmt.Println("val: ", strings.Join(v, ""))
	//
	//}

	fmt.Fprint(w, "<a href='https://google.com'>google</a>")
}

func main() {
	//fmt.Println("Test!")
	http.HandleFunc("/", HomeRouterHandler) // установим роутер

	err := http.ListenAndServe(":9020", nil) // задаем слушать порт

	if err != nil {

		log.Fatal("ListenAndServe: ", err)

	}

}