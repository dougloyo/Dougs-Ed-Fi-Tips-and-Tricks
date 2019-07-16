$ErrorActionPreference = "Stop"

function Pause([string]$message) {
    Write-Host $message
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

function Set-Clipboard {
    $input | PowerShell -NoProfile -STA -Command {
        Add-Type -AssemblyName "System.Windows.Forms"
        [Windows.Forms.Clipboard]::SetText($input)
    }
}

$connection = New-Object System.Data.SqlClient.SqlConnection ("Data Source=.;Initial Catalog=Edfi_Glendale_v31;Integrated Security=SSPI")
$connection.Open()
$command = $connection.CreateCommand() 
$command.CommandText = @"
DECLARE @values nvarchar(max);
SET @values = 
(
    SELECT '
        (''' + REPLACE(name, '''', '''''') + ''', ' + CAST(principal_id AS VARCHAR(100)) +', ' + CAST(version AS VARCHAR(100)) + ', ' + sys.fn_varbintohexstr(definition) + '),'
    FROM sysdiagrams
    FOR XML PATH(''), TYPE
).value('.', 'nvarchar(max)');
SET @values = LEFT(@values, LEN(@values) - 1);

SELECT
'IF OBJECT_ID(N''dbo.sysdiagrams'') IS NULL
    CREATE TABLE dbo.sysdiagrams
    (
        name sysname NOT NULL,
        principal_id int NOT NULL,
        diagram_id int PRIMARY KEY IDENTITY,
        version int,

        definition varbinary(max)
        CONSTRAINT UK_principal_name UNIQUE
        (
            principal_id,
            name
        )
    );

MERGE sysdiagrams AS Target
    USING
    (
        VALUES' + @values + '
    ) AS Source (name, principal_id, version, definition)
    ON Target.name = Source.name
        AND Target.principal_id = Source.principal_id
    WHEN MATCHED THEN
        UPDATE SET version = Source.version, definition = Source.definition
    WHEN NOT MATCHED BY Target THEN
        INSERT (name, principal_id, version, definition)
        VALUES (name, principal_id, version, definition);
';
"@

$command.CommandTimeout = 60
$result = $command.ExecuteScalar()
$command.Dispose()
$connection.Dispose()

Pause "Press any key to copy the resulting SQL to the clipboard..."
$result | Set-Clipboard