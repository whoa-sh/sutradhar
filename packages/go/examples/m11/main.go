package main

import (
	"fmt"

	sdk "github.com/whoa-sh/sutradhar/packages/go/sh/whoa/sutradhar/sdk/v1"
)

func main() {
	fmt.Println("Sutradhar Go consumer example")
	fmt.Printf("Topics: %v\n", sdk.TopicNames)
	fmt.Printf("Headers: %v\n", sdk.HeaderNames)
}
