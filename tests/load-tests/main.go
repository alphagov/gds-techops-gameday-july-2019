package main

import (
	"fmt"
	"net/url"
	"os"
	"time"

	"github.com/alecthomas/kingpin"
	"github.com/icrowley/fake"
	vegeta "github.com/tsenart/vegeta/lib"
)

var (
	rps      = kingpin.Flag("rps", "requests per sec").Default("10").Envar("RPS").Int()
	duration = kingpin.Flag("duration", "duration seconds").Default("10s").Envar("DURATION").Duration()
	target   = kingpin.Flag("target", "URI of target").Required().Envar("TARGET").URL()
)

type RandomUserGenerator struct {
	target url.URL
}

func NewStaticTargeter(target url.URL) func(*vegeta.Target) error {
	return func(t *vegeta.Target) error {
		t.Method = "POST"
		t.URL = target.String()
		t.Body = []byte(fmt.Sprintf(
			"first_name=%s&last_name=%s",
			fake.FirstName(), fake.LastName(),
		))
		return nil
	}
}

func main() {
	kingpin.Parse()

	fmt.Printf(
		"Starting to test %s with %d rps for %2f seconds\n",
		(**target).String(), *rps, (*duration).Seconds(),
	)

	targeter := NewStaticTargeter(**target)
	attacker := vegeta.NewAttacker(
		vegeta.Workers(100),
		vegeta.Timeout(500*time.Millisecond),
		vegeta.Connections(100),
	)
	results := attacker.Attack(
		targeter,
		vegeta.Rate{Freq: *rps, Per: 1 * time.Second},
		*duration,
		(**target).String(),
	)

	resultCounters := make(map[int]int, 0)
outer:
	for {
		select {
		case result := <-results:
			if result == nil {
				fmt.Println("We are done")
				break outer
			} else {
				resultCounters[int(result.Code)]++
			}
		}
	}

	goodResponses := 0
	badResponses := 0

	for code, counter := range resultCounters {
		if code == 200 {
			goodResponses += counter
		} else {
			badResponses += counter
		}
	}

	fmt.Printf(
		"%d / %d (%5f%%) responses were successful\n",
		goodResponses, goodResponses+badResponses,
		100*float64(goodResponses)/float64(goodResponses+badResponses),
	)

	if badResponses == 0 {
		fmt.Println("Success")
		os.Exit(0)
	} else {
		fmt.Println("Failure")
		os.Exit(1)
	}
}
