package main

import (
	"bufio"
	"crypto/aes"
	"crypto/cipher"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/smtp"
	"os"
	"crypto/md5"
	"encoding/hex"
)

func createHash(key string) string {
	hasher := md5.New()
	hasher.Write([]byte(key))
	return hex.EncodeToString(hasher.Sum(nil))
}

func decrypt(data []byte, passphrase string) []byte {
	key := []byte(createHash(passphrase))
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		panic(err.Error())
	}
	nonceSize := gcm.NonceSize()
	nonce, ciphertext := data[:nonceSize], data[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		panic(err.Error())
	}
	return plaintext
}

// Password represents encrypted password
type Password struct {
	Secret     []byte `json:"secret"`
	Passphrase string `json:"passphrase"`
}

type Config struct {
	Host     string   `json:"host"`
	Port     int      `json:"port"`
	Sender   string   `json:"sender"`
	Password Password `json:"password"`
}

func getConfig(path string) Config {
	jsonFile, err := os.Open(path)
	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()
	byteValue, _ := ioutil.ReadAll(jsonFile)
	var config Config
	json.Unmarshal(byteValue, &config)
	return config
}

func main() {
	var configPath string
	flag.StringVar(&configPath, "config", "config.json", "path to config file")
	flag.Parse()

	config := getConfig(configPath)

	// авторизация
	auth := smtp.PlainAuth("", config.Sender, string(decrypt(config.Password.Secret, config.Password.Passphrase)), config.Host)

	// формирование сообщения
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("to:")
	scanner.Scan()
	to := scanner.Text()
	fmt.Println("subject:")
	scanner.Scan()
	subject := scanner.Text()
	fmt.Println("message:")
	scanner.Scan()
	messageBody := scanner.Text()
	// отправка сообщения
	err := smtp.SendMail(
		fmt.Sprintf("%s:%d", config.Host, config.Port),
		auth,
		config.Sender,
		[]string{
			to,
		},
		[]byte(fmt.Sprintf("To: %s\r\nSubject: %s\r\n\r\n%s\r\n", to, subject, messageBody)),
	)
	if err != nil {
		log.Fatal(err)
	}
}
