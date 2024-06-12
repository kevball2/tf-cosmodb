function Update-Readme {
  if (Get-Command "terraform-docs" -ErrorAction SilentlyContinue) {
      $docs = Get-ChildItem -path . -Filter ".terraform-docs.yml"  -Recurse
      foreach ($doc in $docs) {
          if($doc.Directory.ToString().Contains("examples") -and !$doc.Directory.ToString().Contains(".terraform")) {
            $examples = Get-ChildItem -Path .\examples\ -Directory
              foreach ($example in $examples) {
                Write-Host "Running terraform-docs for: $($example.Name) using $($doc.FullName)" -ForegroundColor Green
                Invoke-Expression -Command "& terraform-docs -c $($doc.FullName) $($example.FullName)"
              }
          }
          elseif (!$doc.Directory.ToString().Contains(".terraform")) {
            Write-Host "Running terraform-docs for: $($doc.Name) using $($doc.FullName)" -ForegroundColor Green
            Invoke-Expression -Command "& terraform-docs -c $($doc.FullName) $($doc.Directory)"
          }

      }
  }
  else {
      Write-Error 'Unable to find terraform-docs, please ensure it is installed and part your environment path'
  }
}

function Invoke-Tflint {
  if (Get-Command "tflint" -ErrorAction SilentlyContinue) {

      if (($(Get-ChildItem -path . -Filter "ecm.tflint.hcl"  -Recurse).count -eq 1) -and ($(Get-ChildItem -path . -Filter "ecm.tflint_example.hcl"  -Recurse).count -eq 1)) {
        $tflintConfig = Get-ChildItem -path . -Filter "ecm.tflint.hcl"  -Recurse
        $tflintExampleConfig = Get-ChildItem -path . -Filter "ecm.tflint_example.hcl"  -Recurse
      }
      else {
        Write-Error 'Unable to find tflint configuraion files in project, please ensure that "ecm.tflint.hcl" and "ecm.tflint_example.hcl" are presenet in your project'
      }
      Invoke-Expression -Command "& tflint --init --config=$($tflintConfig.FullName)"
      Invoke-Expression -Command "& tflint --config=$($tflintConfig.FullName)"

      Get-ChildItem -Path .\examples\ -Directory | ForEach-Object {

          Invoke-Expression -Command "& tflint --init --config=$($tflintExampleConfig.FullName) --chdir=$($_.FullName)"
          Invoke-Expression -Command "& tflint --config=$($tflintExampleConfig.FullName) --chdir=$($_.FullName)"
      }
  }
  else {
      Write-Error 'Unable to find tflint, please ensure it is installed and part your environment path'
  }
}

function Invoke-TFformat {
  if (Get-Command "terraform" -ErrorAction SilentlyContinue) {
      Invoke-Expression -Command "& terraform fmt -recursive"
  }
  else {
      Write-Error 'Unable to find terraform, please ensure it is installed and part your environment path'
  }

}

function Invoke-TFvalidate {
  if (Get-Command "terraform" -ErrorAction SilentlyContinue) {
      $examples = Get-ChildItem -path . -Filter "main.tf" -Recurse | Where-Object { $_.FullName -notlike "*.terraform*" }
      $rootFolder = Get-Location
      foreach ($example in $examples) {
          $example.Directory
          Set-Location $example.Directory
          Invoke-Expression -Command "& terraform init"
          Invoke-Expression -Command "& terraform validate"

      }
      Set-Location $rootFolder
  }
  else {
      Write-Error 'Unable to find terraform, please ensure it is installed and part your environment path'
  }
}

function Invoke-TFtest {
  [CmdletBinding()]
  param (
      [parameter(Mandatory,
          HelpMessage = "Enter the location for resource deployment")]
      [ValidateSet("eastus", "usgovvirginia")]
      [string]$location
  )


  if (Get-Command "az" -ErrorAction SilentlyContinue)
  {
      Invoke-Expression -Command "& az account list-locations --output none"
      if( $LASTEXITCODE -eq 0) {
          if (Get-Command "terraform" -ErrorAction SilentlyContinue && $(Get-ChildItem .\tests -Recurse -File -Filter *.hcl).count -ge 1) {
              Invoke-Expression -Command "& terraform test -test-directory=tests\unit -var=location=$location"
          }
          else {
              Write-Error 'Unable to find terraform, please ensure it is installed and part your environment path'
          }
      }
      else {
          Write-Error "Verify Azure CLI is logged in to the correct Azure tenant. CLI must be logged in to run tests locally"
      }
  }
  else {
      Write-Error 'Unable to find Azure CLI, please ensure it is installed and part your environment path'
  }




}

function Invoke-PrCheck {
  [CmdletBinding()]
  param (
      [parameter(Mandatory,
          HelpMessage = "Enter the location for resource deployment")]
      [ValidateSet("eastus", "usgovvirginia")]
      [string]$location
  )


  Write-Host "---------------------------"
  Write-Host "Updating Documentation"
  Write-Host "---------------------------"
  Update-Readme
  Write-Host "---------------------------"
  Write-Host "Formatting Terraform Files"
  Write-Host "---------------------------"
  Invoke-TFformat
  Write-Host "---------------------------"
  Write-Host "Validating Terraform Files"
  Write-Host "---------------------------"
  Invoke-TFvalidate
  Write-Host "---------------------------"
  Write-Host "Linting Terraform Files"
  Write-Host "---------------------------"
  Invoke-Tflint
  Write-Host "---------------------------"
  Write-Host "Running Terraform Tests"
  Write-Host "---------------------------"
  Invoke-TFtest -location $location



}
