package main

import (
	"fmt"
	"os"
)

func main() {
	if os.Getenv("I_USE_DIRENV_BTW") == "1" {
		fmt.Println("Welcome!")
	} else {
		fmt.Println("Hello world")
	}
}
