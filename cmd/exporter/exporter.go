/*
Copyright © 2024 Julien Saevecke Julien.Saevecke@googlemail.com
*/
package exporter

import (
	"github.com/spf13/cobra"
)

type listOptions struct {
	options []string
}

type Options struct {
}

var ExporterCmd = &cobra.Command{
	Use:   "exporter",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		_ = cmd.Help()
	},
}
