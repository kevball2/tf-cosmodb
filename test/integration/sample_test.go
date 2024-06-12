package ecm_tester

import (
	"log"
	"os"
	"path/filepath"
	"testing"

	terraform_module_test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIntegrationNetworkSecurityGroupExists(t *testing.T) {
	dir := filepath.Join("../../", "examples")
	location := os.Getenv("LOCATION")
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		t.Fatalf("Directory %s does not exist", dir)
	}
	files, err := os.ReadDir(dir)
	if err != nil {

		log.Fatal(err)
	}

	for _, file := range files {
		if file.IsDir() {
			file.Info()
			t.Run(file.Name(), func(t *testing.T) {
				terraform_module_test_helper.RunE2ETest(t, "../../", filepath.Join("examples", file.Name()), terraform.Options{
					Vars: map[string]interface{}{
						"location": location,
					},
				},
					func(t *testing.T, output terraform_module_test_helper.TerraformOutput) {
						resourceGroupName, ok_rg := output["resource_group_name"].(string)
						//subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
						assert.True(t, ok_rg, "Resource group: %s does not exist", resourceGroupName)
					})
			})
		}
	}
}
