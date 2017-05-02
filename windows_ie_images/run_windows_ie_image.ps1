param(
    [Parameter(Mandatory=$true)]
    [String]$os
    )

$packages = @("vagrant", "virtualbox", "7zip")

function whichVm($configuration){
    switch($os){
        "ie8w7" {"https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE8/IE8.Win7.Vagrant.zip"}
        "ie9w7" {"https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE9/IE9.Win7.Vagrant.zip"}
        "ie10w7" {"https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE10/IE10.Win7.Vagrant.zip"}
        "ie11w7" {"https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip"}
    }
}

function getVm($os){
    $url = whichVm($os)
    $path = Join-Path -Path (Get-Location) -ChildPath ($url.Split("/")[-1])
    Write-Host ("Downloading {0} from {1} to {2}" -f $url.Split("/")[-1], $url, $path) -f green
    if(Test-Path $path){
        Write-Host "File already exists" -f green
        } else {
            (new-object System.Net.WebClient).DownloadFile($url, $path)
            Write-Host "Download Complete" -f green
        }
    $path
}

function checkExecPolicy{
    if((Get-ExecutionPolicy) -eq "Restricted"){
        Write-Host "Changing Execution Policy" -f yellow
        Set-ExecutionPolicy AllSigned
    } else {
        Write-Host "Execution Policy not Restricted" -f green
    }
}

function installChoco{
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function installPackages($packages){
    foreach($package in $packages){
        choco install $package -y
    }
}

function unzipBox($path){
    $p = Start-Process 7z -ArgumentList "e $path -y" -Wait -NoNewWindow -PassThru
    if($p.ExitCode -ne 0){
        Throw "Unzip Failed!"
        Exit 1
    }
    $path = Join-Path (Get-Location) (Get-ChildItem -Filter *.box)
    $path
}

function addBox($os, $path){
    Write-Host "Adding box $os at path $path to Vagrant..." -f green
    $p = Start-Process vagrant -ArgumentList "box add --name $os '$path'" -Wait -NoNewWindow -PassThru
    if($p.ExitCode -ne 0){
        Throw "Vagrant Add Failed!"
        Exit 1
    }
}

checkExecPolicy
installChoco
installPackages $packages
$path = unzipBox (getVm $os)
addBox $os $path
