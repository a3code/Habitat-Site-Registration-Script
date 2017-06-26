<# 
   This Script Help to register web site unders IIS.

   Authour: Agalakov Oleksandr
   Date: 15.06.2017

   Issue: Start 2 times for the same solution, could call issue that site can't be created.
           New-IISSite : Filename: \?\C:\Windows\system32\inetsrv\config\applicationHost.config Error: Cannot commit configuration changes because the file has changed on disk
   Solution: Restart PC should fix an issue.

 #>

Import-Module "WebAdministration"

<# Function add records to hosts file #>
function add-host([string]$ip, [string]$hostname) {
    Write-Host "Add site to hosts file"
    $file = "C:\Windows\System32\drivers\etc\hosts"
	<#remove-host $file $hostname#>	
    "`r`n" + $ip + "`t" + $hostname | Out-File -encoding ASCII -append $file
}

<# Function add register web site #>
function registerWebSite([string]$siteName, [string]$binding, [string]$physicalPath )
{
    Write-Host "Creating App Pool - $siteName"
    New-WebAppPool -Name $siteName -Force
    Write-Host "Creating Web Site Pool - $siteName"
    New-IISSite -BindingInformation $binding -Name $siteName -PhysicalPath "$physicalPath" -Force
    Write-Host "Mapping Pull and Web Site - $strIssSiteName"
    Set-ItemProperty "IIS:\Sites\$siteName" -name applicationPool -value $siteName
        
    add-host "127.0.0.1" $siteName       

    Write-Host "$siteName WebSite Created"
}

$strCurrentPath = $MyInvocation.MyCommand.Path
$strWebSiteFolder = Get-ChildItem (dir $strCurrentPath)
$strWebSiteBindingPath = $strWebSiteFolder.Directory.FullName+"\build\WebSite"
$strCurrentFolderName = $strWebSiteFolder.Directory.Name
$strIssSiteName = "$strCurrentFolderName.local"
$strIssBindigFormat = "*:80:$strIssSiteName"


$title = "Use default site parameters"
$message = "Do agree to use default site settings ?`r`n IIS Web Site phycical path: $strWebSiteBindingPath `r`nIIS SiteName & AppPool Name: $strIssSiteName `r`nIP: 127.0.0.1:80 will added to host file"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Agree"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", ""
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {
            registerWebSite $strIssSiteName $strIssBindigFormat $strWebSiteBindingPath
          }
        1 { 
            $strIssSiteName = Read-Host -Prompt "Please input web site name (for example: $strIssSiteName). This name will be used at IIS"
            $title = "Use new site parameters"
            $message = "Do agree to use site settings ?`r`nIIS Web Site phycical path: $strWebSiteBindingPath `r`nIIS SiteName & AppPool Name: $strIssSiteName `r`nIP: 127.0.0.1:80 will added to host file"
            $customResult = $host.ui.PromptForChoice($title, $message, $options, 0) 
            switch ($customResult)
                {
                0 {
                     registerWebSite $strIssSiteName $strIssBindigFormat $strWebSiteBindingPath
                  }
                1 {
                    Write-Host "Your always welcome to change your choose. Start Script from scratch"
                }
                }
                
          }
    }