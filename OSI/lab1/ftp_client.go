package main

import (
	//"net/http" // пакет для поддержки HTTP протокола

	"bytes"
	"os"

	//"strings" // пакет для работы с UTF-8 строками
	"strings"
	"fmt"
	"log" // пакет для логирования

	"time"
	//"github.com/RealJK/rss-parser-go"
	"github.com/jlaffaye/ftp"
	"io"
	"io/ioutil"
	"github.com/skorobogatov/input"
)

func Dial(adress string) (*ftp.ServerConn){
	c, err := ftp.Dial(adress, ftp.DialWithTimeout(5*time.Second))
	if err != nil {
		log.Fatal(err)
	}
	return c
}
func login(login string, passw string, c *ftp.ServerConn) {
	err := c.Login(login, passw)
	if err != nil {
		log.Fatal(err)
	}
}
func stor(name string, data io.Reader, c *ftp.ServerConn) {
	err := c.Stor("data.txt", data)
	if err != nil {
		log.Fatal(err)
	}
}
func retr(path string, c *ftp.ServerConn) (string) {
	r, err := c.Retr(path)
	if err != nil {
		log.Fatal(err)
	}
	buf, err := ioutil.ReadAll(r)
	return string(buf)
}
func connectToYss() (*ftp.ServerConn) {
	c := Dial("students.yss.su:20")
	login("ftpiu8",  "3Ru7yOTA", c)
	i, _ := c.NameList("")
	fmt.Printf("%s", i)
	return c
}
func connectToU33() (*ftp.ServerConn) {
	c := Dial("185.20.227.83:2121")
	login("admin",  "123456", c)
	return c
}
func main() {
	c := connectToU33()
	data := ""
	data = input.Gets()
	for data != "\n" {
		uuu := strings.Split(data, " ")
		switch uuu[0] {
		case "makefile":
			file, _ := ioutil.ReadFile(uuu[1])
			datai := bytes.NewBuffer(file)
			stor(uuu[1], datai, c)
			break
		case "makedir":
			c.MakeDir(uuu[1])
			break
			case "deldir":
			c.RemoveDir(uuu[1])
			break
		case "retrfile":
			//fmt.Print(retr(uuu[1], c))
			file, _ := os.Create(uuu[1])
			file.WriteString(retr(uuu[1], c))
			file.Close()
			break
		}

		data = input.Gets()
	}
	fmt.Println(c.NameList(""))
	c.Logout()
}