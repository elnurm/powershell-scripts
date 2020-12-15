param (
    [string]$JfrogUsername,
	[string]$JfrogPassword
)

$jfrog = "$ENV:WORKSPACE\jfrog.exe"
$specFile = "$ENV:WORKSPACE\artifactory.spec"

Write-Host "Configuring jfrog cli"
&$jfrog rt c epam-artifactory --url=https://artifactory.example.com/artifactory --user=$JfrogUsername --password=$JfrogPassword --interactive=false

if ($LASTEXITCODE -ne 0) {
	Write-Host "Error in jfrog cli configuration."
	Write-Host $Error[0]
	Exit 1
}
Write-Host "jfrog cli configured successfully"


Write-Host "Searching and deleting old artifacts"
&$jfrog rt delete --spec $specFile --quiet