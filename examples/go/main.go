package main

import (
	"fmt"

	sdk "github.com/whoa-sh/sutradhar/packages/go/sh/whoa/sutradhar/sdk/v1"
)

func main() {
	fmt.Println("Sutradhar Go consumer example")
	fmt.Printf("Topic: %s\n", sdk.TopicNotificationRequested)
	fmt.Printf("Header: %s\n", sdk.HeaderTraceID)
}
