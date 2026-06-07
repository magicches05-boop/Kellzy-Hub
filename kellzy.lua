<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Script Hub</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        body {
            /* Background gradasi gelap yang profesional dan clean */
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #f8fafc;
        }
        .container {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 2.5rem 2rem;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .header h1 {
            font-size: 1.6rem;
            color: #38bdf8;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .header p {
            font-size: 0.9rem;
            color: #94a3b8;
            margin-top: 0.5rem;
        }
        .code-box {
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        code {
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.85rem;
            color: #e2e8f0;
            word-wrap: break-word;
        }
        .btn-copy {
            width: 100%;
            padding: 0.85rem;
            background: #0ea5e9;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        .btn-copy:hover {
            background: #0284c7;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Script Premium</h1>
            <p>Copy script di bawah dan paste di executor kamu.</p>
        </div>
        
        <div class="code-box">
            <code id="scriptCode">getgenv().Key = "KELLYZ-2X5NYFU6"; loadstring(game:HttpGet("LINK_RAW_GITHUB_KAMU_DISINI"))()</code>
        </div>

        <button class="btn-copy" onclick="copyScript()">Copy Loadstring</button>
    </div>

    <script>
        function copyScript() {
            var copyText = document.getElementById("scriptCode").innerText;
            navigator.clipboard.writeText(copyText).then(function() {
                var btn = document.querySelector('.btn-copy');
                btn.innerText = "Berhasil Dicopy!";
                btn.style.background = "#10b981"; // Berubah hijau saat sukses
                
                setTimeout(function() {
                    btn.innerText = "Copy Loadstring";
                    btn.style.background = "#0ea5e9"; // Kembali ke warna semula
                }, 2000);
            });
        }
    </script>
</body>
</html>
