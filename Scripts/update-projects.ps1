param (
    [string] $directory = "~/Source/rise_x/diana-services/Src",
    [string] $fromTargetFramework = "netstandard2.1",
    [string] $targetFramework = "netstandard2.1",
    [switch] $migrate = $false,
    [switch] $update = $false,
    [switch] $clean = $false,
    [switch] $restore = $false
)

$migrateHelp = "https://docs.microsoft.com/en-us/aspnet/core/migration/22-to-31?view=aspnetcore-2.2&tabs=visual-studio"

function Restore-Projects([string] $directory)
{
    Write-Host "Restore Projects"

    $projectFiles = Get-ChildItem $directory -Recurse -Filter *.csproj

    foreach($projectFile in $projectFiles)
    {
        Write-Host "  Project: $($projectFile.Name)"
        $command = "dotnet restore ""$($projectFile.Directory.FullName)"""
        if($update)
        {
            Invoke-Expression $command | Out-File -FilePath "dotnet.log" -Append
        }
    }
}

function Update-Framework([string] $directory, [string] $targetFramework)
{
    if($migrate -eq $true)
    {
        $projectFiles = Get-ChildItem $directory -Recurse -Filter *.csproj
        Write-Host "Update Projects"
        foreach($projectFile in $projectFiles)
        {
            $projectXml = [xml](Get-Content $projectFile.FullName)

            if($projectXml.Project.Sdk -ne "")
            {
                Write-Host "  Project: $($projectFile.Name) Current Setting: $($projectXml.Project.PropertyGroup.TargetFramework)"

                if($projectXml.Project.PropertyGroup.TargetFramework -eq $fromTargetFramework)
                {
                    Write-Host "    Migrate Project to $targetFramework"

                    if($null -ne $projectXml.Project.PropertyGroup[0].TargetFramework)
                    {
                        $projectXml.Project.PropertyGroup[0].TargetFramework = $targetFramework
                    }
                    else
                    {
                        $projectXml.Project.PropertyGroup.TargetFramework = $targetFramework
                    } 
                    $projectXml.Save($projectFile.FullName)
                }
                
            }
        }
    }
}

function Update-Packages([string] $directory, [string] $targetFramework)
{
    if($update -eq $true)
    {
        $projectFiles = Get-ChildItem $directory -Recurse -Filter *.csproj
        Write-Host "Update Projects"
        foreach($projectFile in $projectFiles)
        {
            $projectXml = [xml](Get-Content $projectFile.FullName)

            if($projectXml.Project.Sdk -ne "")
            {
                $itemGroups = $projectXml.Project.ItemGroup

                Write-Host "  Project: $($projectFile.Name) Current Setting: $($projectXml.Project.PropertyGroup.TargetFramework)"


                Write-Host "    Update Packages:"

                foreach($itemGroup in $itemGroups)
                {
                    if($itemGroup.PackageReference)
                    {
                        foreach($packageRef in $itemGroup.PackageReference)
                        {
                            Write-Host "      Package: $($packageRef.Include)"
                            $command = "dotnet add ""$($projectFile)"" package $($packageRef.Include)"
                            Invoke-Expression $command | Out-File -FilePath "dotnet.log" -Append
                        }
                    }
                }
                
            }
        }
    }
}
function Update-Launch([string] $directory, [string] $targetFramework)
{
    Write-Host "Migrate Launch Files"
    $launchFiles = Get-ChildItem $directory -Recurse -Force -Filter launch.json

    foreach($launchFile in $launchFiles)
    {
        Write-Host "." -NoNewline
        #Write-Host "  $($launchFile.ParentDirectory.ParentDirectory.Name)"
        $newContent = (Get-Content $launchFile -Raw) -replace "/$fromTargetFramework/", "/$targetFramework/"
        #Write-Host $newContent
        $newContent | Set-Content -Path $launchFile.FullName
    }
    Write-Host " [done]"
}

function Remove-Bin([string] $directory)
{
    Write-Host "Remove Bin Directories"
    $binDirectories = Get-ChildItem $directory -Recurse -Force -Directory -Filter bin

    foreach($binDirectory in $binDirectories)
    {
        Write-Host "." -NoNewline
        Remove-Item -Path $binDirectory.FullName -Recurse -Force
    }
    Write-Host " [done]"
}

function Remove-Obj([string] $directory)
{
    Write-Host "Remove Obj Directories"
    $binDirectories = Get-ChildItem $directory -Recurse -Force -Directory -Filter obj

    foreach($binDirectory in $binDirectories)
    {
        Write-Host "." -NoNewline
        Remove-Item -Path $binDirectory.FullName -Recurse -Force
    }
    Write-Host " [done]"
}


function Main([string] $directory, [string] $targetFramework)
{
    $validSettings = $restore -or $clean -or $migrate -or $update

    if($validSettings -eq $false)
    {
        Write-Host ""
        Write-Host "Usage:"
        Write-Host "migrate-projects.ps1 -directory [dir] -clean -migrate -restore -update"
        Write-Host ""
        Write-Host " -clean : removes bin and obj directories recursively"
        Write-Host " -clean : removes bin and obj directories recursively"
        Write-Host " -migrate : replaces the current framework with the target framework"
        Write-Host " -update : re-adds the packages to force version update to latest package version"
        Write-Host " -restore : forces a dotnet restore on all the projects"
        Write-Host " -fromTargetFramework : the framework to update netstandard2.1, netcoreapp3.1 etc"
        Write-Host " -targetFramework : the new framework version netstandard2.1, netcoreapp3.1 etc"
        Write-Host ""
        Write-Host ""
    }
    Write-Host "Current Values:"
    Write-Host "  -directory: $directory"
    Write-Host "  -clean    : $clean"
    Write-Host "  -migrate  : $migrate"
    Write-Host "  -update   : $update"
    Write-Host "  -restore  : $restore"
    Write-Host "  -fromTargetFramework : $fromTargetFramework"
    Write-Host "  -targetFramework     : $targetFramework"

    if($clean)
    {
        Remove-Obj -directory $directory
        Remove-Bin -directory $directory
    }

    if($migrate)
    {
        Update-Framework -directory $directory -targetFramework $targetFramework
        Update-Launch -directory $directory -targetFramework $targetFramework
    }

    if($update)
    {
        Update-Packages -directory $directory -targetFramework $targetFramework
    }

    if($restore)
    {
        Restore-Projects -directory $directory
    }
}

Main -directory $directory -targetFramework $targetFramework