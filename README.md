# issue sqlpackage partitions

Demonstration of a possible issue in sqlpackage



# how to run


1) Install the Microsoft.SqlPackage dotnet tool
2) go to the root of the project
3) run dotnet build
4) Run the publishLocal script
    
  

``` Powershell
dotnet tool install --global Microsoft.SqlPackage --version 162.0.52
dotnet build
./scripts/publishLocal.ps1
```



### publishLocal.ps1 :
This script will look for the latest dacpac in debug and release folder.
If both exists, the latest file will be used. Otherwise the existing one will be used.

Once the dacpac is defined,it is published to a local sql server '.', using database name **partitionsTest**

Afterwards a **change.sql** is generated, a script showing the changes between the published version and the dacpac. This should be an empty script,
yet it isn't.


# versions used
    
Project sdk
    
``` xml
<Sdk Name="Microsoft.Build.Sql" Version="0.1.10-preview" />
```


``` powershell
sqlpackage /version
162.0.52.1
````
