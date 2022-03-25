package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"net"
	"os"

	"golang.org/x/crypto/ssh"
)

func main() {
	var (
		host     string
		port     int
		user     string
		password string
	)

	//flag.StringVar(&host, "h", "185.20.227.83", "ssh server address")
	//flag.IntVar(&port, "port", 22, "port of ssh server")
	//flag.StringVar(&user, "u", "iu9_32_20", "username")
	//flag.StringVar(&password, "p", "altovod19", "1233456")

	flag.StringVar(&host, "h", "185.20.227.83", "ssh server address")
	flag.IntVar(&port, "port", 2120, "port of ssh server")
	flag.StringVar(&user, "u", "admin", "username")
	flag.StringVar(&password, "p", "123456", "1233456")

	flag.Parse()

	config := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{
			ssh.Password(password)},
		HostKeyCallback: func(hostname string, remote net.Addr, key ssh.PublicKey) error {
			return nil
		}}

	client, err := ssh.Dial("tcp", fmt.Sprintf("%s:%d", host, port), config)
	if err != nil {
		panic(err)
	}

	session, err := client.NewSession()
	if err != nil {
		panic(err)
	}
	defer session.Close()

		stdin, err := session.StdinPipe()
	if err != nil {
		log.Fatal(err)
	}

	session.Stdout = os.Stdout
	session.Stderr = os.Stderr

	err = session.Shell()
	if err != nil {
		log.Fatal(err)
	}

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		s := scanner.Text()
		_, err = fmt.Fprintf(stdin, "%s\n", s)
		if err != nil {
			log.Fatal(err)
		}
		if s == "exit" {
			break
		}
	}

	err = session.Wait()
	if err != nil {
		log.Fatal(err)
	}
}
