# 简单的HTTP服务器
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

Write-Host "服务器已启动: http://localhost:8000/"
Write-Host "按 Ctrl+C 停止服务器"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $path = $request.Url.LocalPath
    if ($path -eq "/") {
        $path = "/index.html"
    }
    
    $filePath = $PSScriptRoot + $path
    
    if (Test-Path $filePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $content = "Page not found"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    
    $response.Close()
}

$listener.Stop()
