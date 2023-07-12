$dbName = 'PartitionsTest'
$dpName ="$dbName.dacpac"

$dst = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,'data'));
$op = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,'change.sql'));
$dpPath = [IO.Path]::Combine($dst,$dpName);


#clean existing local files
Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $dst > $null;

Remove-Item $op -ErrorAction SilentlyContinue

#FIRST LOOK FOR THE LATEST FILE IN DEBUG OR RELEASE FOLDER
$filenames = @(
	[IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,"..\$dbName\bin\Release\$dpName")),
	[IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,"..\$dbName\bin\Debug\$dpName"))
);

$src = $null
$mostRecentTime = [datetime]::MinValue

foreach ($filename in $filenames) {
    if (Test-Path $filename) {
        $file = Get-Item $filename
        if ($file.LastWriteTime -gt $mostRecentTime) {
            $src = $file
            $mostRecentTime = $file.LastWriteTime
        }
    }
}
if ($src -eq $null) {
    Write-host -ForegroundColor DarkRed "None of the files exist."
    exit;
}

Write-Host -ForegroundColor DarkYellow "Using $src";

#copy the file localy
Copy-Item $src $dst;
Write-Host -ForegroundColor DarkYellow "Dacpac creationtime: " (Get-Item $dst).LastWriteTime;

#now that we have the wanted file,   publish it to local DB
#then generate a change script
# The change script should not contain  "INSERT INTO" statements

sqlpackage /version:true;

sqlpackage -action:Publish -sourcefile:"$dpPath" -targetServername:'.' -targetdatabasename:"$dbName" /TargetTrustServerCertificate:true /p:GenerateSmartDefaults='True'
Write-Host '------- done publishing --------';
Write-Host 'Now create a change.sql file,  there should be no change imho, as we just published, yet the entire table is recreated';
sqlpackage -action:script -sourcefile:"$dpPath" -targetServername:'.' -targetdatabasename:"$dbName"  -outputPath:"$op" /TargetTrustServerCertificate:true /p:GenerateSmartDefaults='True'
Write-Host '------- change.sql generated --------';

get-content $op | Select-String 'INSERT INTO' -List


