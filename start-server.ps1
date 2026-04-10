# 简单的HTTP服务器脚本
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "服务器启动在 http://localhost:8000/"
Write-Host "按 Ctrl+C 停止服务器"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    # 获取请求的路径
    $path = $request.Url.LocalPath
    
    # 默认路径为index.html
    if ($path -eq "/") {
        $path = "/index.html"
    }
    
    # 构建文件路径
    $filePath = Join-Path -Path $PSScriptRoot -ChildPath $path.TrimStart("/")
    
    # 检查文件是否存在
    if (Test-Path -Path $filePath -PathType Leaf) {
        # 读取文件内容
        $content = Get-Content -Path $filePath -Raw
        
        # 设置响应内容类型
        $extension = [System.IO.Path]::GetExtension($filePath)
        switch ($extension) {
            ".html" { $response.ContentType = "text/html" }
            ".css" { $response.ContentType = "text/css" }
            ".js" { $response.ContentType = "application/javascript" }
            ".png" { $response.ContentType = "image/png" }
            ".jpg" { $response.ContentType = "image/jpeg" }
            ".gif" { $response.ContentType = "image/gif" }
            default { $response.ContentType = "application/octet-stream" }
        }
        
        # 发送响应
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } else {
        # 文件不存在，返回404
        $response.StatusCode = 404
        $content = "<html><body><h1>404 Not Found</h1></body></html>"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()
}

$listener.Stop()
$listener.Dispose()
