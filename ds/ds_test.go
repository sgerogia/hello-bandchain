package main

import (
	"github.com/stretchr/testify/require"
	"os"
	"runtime"
	"testing"
	"path/filepath"
)

func TestReadConfig(t *testing.T) {
	tests := []struct {
		name         string
		expected     ApiResult
		testDataFile string
	}{
		{
			"full data file",
			ApiResult{
				Flight{
					Arrival: Arrival{
						Airport: Airport{
							Iata: "LHR",
						},
						ActualTimeUtc:    "2022-06-01 13:03Z",
						ScheduledTimeUtc: "2022-06-01 13:25Z",
					},
					Status: "Arrived",
				},
			},
			"../ds_test/response_full.json",
		},
		{
			"partial data file",
			ApiResult{
				Flight{
					Arrival: Arrival{
						Airport: Airport{
							Iata: "LHR",
						},
						ActualTimeUtc:    "",
						ScheduledTimeUtc: "2022-06-15 13:25Z",
					},
					Status: "Unknown",
				},
			},
			"../ds_test/response_partial.json",
		},
	}

	_, testFile, _, _ := runtime.Caller(0)
	dir := filepath.Dir(testFile)

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			testData := filepath.Join(dir, tt.testDataFile)

			jsonFile, err := os.Open(testData)
			require.NoError(t, err)

			defer jsonFile.Close()

			result := ApiResult{}
			err = parse(jsonFile, &result)
			require.NoError(t, err)

			require.Equal(t, tt.expected, result)
		})
	}
}
