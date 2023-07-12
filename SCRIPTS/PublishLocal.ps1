$dbName = 'PartitionsTest'
$dpName ="$dbName.dacpac"

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

Write-Host $src;
Copy-Item $src $dst;
Write-Host -ForegroundColor DarkYellow "Dacpac creationtime: " (Get-Item $srcRelease).CreationTime;

sqlpackage /version:true;

sqlpackage -action:Publish -sourcefile:"$dpPath" -targetServername:'.' -targetdatabasename:"$dbName" /TargetTrustServerCertificate:true /p:GenerateSmartDefaults='True'
Write-Host '------- done publishing --------';
Write-Host 'Now create a change.sql file,  there should be no change imho, as we just published, yet the entire table is recreated';
sqlpackage -action:script -sourcefile:"$dpPath" -targetServername:'.' -targetdatabasename:"$dbName"  -outputPath:"$op" /TargetTrustServerCertificate:true /p:GenerateSmartDefaults='True'
Write-Host '------- change.sql generated --------';

get-content $op | Select-String 'INSERT INTO' -List


