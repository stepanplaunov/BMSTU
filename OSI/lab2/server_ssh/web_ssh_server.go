package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"github.com/gliderlabs/ssh"
)


func main() {
	var port int

	flag.IntVar(&port, "port", 2120, "port of ssh server")

	flag.Parse()

	server := &ssh.Server{
		Addr: fmt.Sprintf(":%d", port),
		Handler: func(s ssh.Session) {
			fmt.Print(s.LocalAddr())
			io.WriteString(s, fmt.Sprintf("You've been connected to %s\n", s.LocalAddr().String()))
			reader := bufio.NewReader(s)
		loop:
			for {
				text, err := reader.ReadString('\n')
				if err != nil {
					fmt.Println("GetLines: " + err.Error())
					break
				}
				fmt.Println(text)

				text = strings.TrimRight(text, "\n")
				re := regexp.MustCompile(`\s+`)
				re.ReplaceAllString(text, " ")
				command := strings.Split(text, " ")

				switch command[0] {
				case "exit":
					break loop
				case "cd":
					if len(command) < 2 {
						home := os.Getenv("HOME")
						os.Chdir(home)
					} else {
						err := os.Chdir(command[1])
						if err != nil {
							io.WriteString(s, err.Error())
						}
					}
				case "echo":
					if len(command) < 2 {
						//io.WriteString(s, "\n")
					} else {
						io.WriteString(s, strings.Join(command[1:], " ")+"\n")
					}
				default:
					out, err := exec.Command(command[0], command[1:]...).Output()
					if err != nil {
						io.WriteString(s, err.Error())
					}
					io.WriteString(s, fmt.Sprintf("%s\n", string(out)))
				}
			}

			err := s.Exit(0)
			if err != nil {
				fmt.Println(err)
			}
		},
		PasswordHandler: func(ctx ssh.Context, password string) bool {
			return ctx.User() == "admin" && password == "123456"
		},
	}

	log.Fatal(server.ListenAndServe())
}
