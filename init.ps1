[CmdletBinding()]
param (
    [string]$virtual_machine_name
)

############# BEGIN SCRIPT ############
powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools

$html_content = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>This is a Windows VM</h1>
        <h1>Hello World from ${virtual_machine_name}</h1>
    </div>
</body>
</html>
"@
$css_content_blue = @"
body {
    margin: 0;
    padding: 0;
    background-color: lightblue;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    font-family: Arial, sans-serif;
}

.container {
    text-align: center;
}

h1 {
    color: black;
    font-size: 2em;
}
"@
$css_content_red = @"
body {
    margin: 0;
    padding: 0;
    background-color: lightcoral;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    font-family: Arial, sans-serif;
}

.container {
    text-align: center;
}

h1 {
    color: black;
    font-size: 2em;
}
"@
$css_content_green = @"
body {
    margin: 0;
    padding: 0;
    background-color: lightgreen;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    font-family: Arial, sans-serif;
}

.container {
    text-align: center;
}

h1 {
    color: black;
    font-size: 2em;
}
"@

New-Item -Type 'Directory' -Path 'C:\inetpub\wwwroot\blue'
Write-Output $html_content > C:\inetpub\wwwroot\blue\index.html
Write-Output $css_content_blue > C:\inetpub\wwwroot\blue\styles.css

New-Item -Type 'Directory' -Path 'C:\inetpub\wwwroot\red'
Write-Output $html_content > C:\inetpub\wwwroot\red\index.html
Write-Output $css_content_red > C:\inetpub\wwwroot\red\styles.css

New-Item -Type 'Directory' -Path 'C:\inetpub\wwwroot\green'
Write-Output $html_content > C:\inetpub\wwwroot\green\index.html
Write-Output $css_content_green > C:\inetpub\wwwroot\green\styles.css
