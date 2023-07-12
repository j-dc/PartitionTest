$dbName = 'PartitionsTest'
$dpName ="$dbName.dacpac"

#FIRST LOOK FOR THE LATEST FILE IN DEBUG OR RELEASE FOLDER

$srcRelease = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,"..\$dbName\bin\Release\$dpName"));
$srcDebug = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,"..\$dbName\bin\Debug\$dpName"));

$src ="";
if((Test-Path $srcDebug) -and (Test-Path $srcRelease)){
	$dRelease = (Get-Item $srcRelease).CreationTime;
	$dDebug = (Get-Item $srcDebug).CreationTime;

	if($dDebug -gt $dRelease){
		Write-Host -ForegroundColor DarkYellow 'Debug will be used' ;
		$src = $srcDebug;
	}else{ 
		Write-Output 'Release will be used.';
		$src = $srcRelease;
	}
} elseif (Test-Path $srcDebug){
	Write-Host -ForegroundColor DarkYellow 'Debug will be used' ;
	$src = $srcDebug;
} elseif (Test-Path $srcRelease){
		Write-Host -ForegroundColor Yellow 'Release will be used.' ;
		$src = $srcRelease;
} else {
	Write-Host "No recent build found" -ForegroundColor DarkRed;
	exit;	
}


$dst = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,'data'));
$op = [IO.Path]::GetFullPath( [IO.Path]::Combine($PSScriptRoot,'change.sql'));
Remove-Item $op -ErrorAction SilentlyContinue

if(-not(test-path $dst)){
	New-Item -ItemType Directory $dst;
}

$dpPath = [IO.Path]::Combine($dst,$dpName);
Remove-Item $dpPath -ErrorAction SilentlyContinue


#copy the file localy
Write-Host $src;
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


