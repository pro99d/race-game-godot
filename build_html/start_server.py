import http.server
import socketserver
import mimetypes

PORT = 8000

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Добавляем заголовки для SharedArrayBuffer и безопасности
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

    def guess_type(self, path):
        # Исправляем MIME-типы для .wasm и других файлов
        if path.endswith('.wasm'):
            return 'application/wasm'
        elif path.endswith('.pck'):
            return 'application/octet-stream'
        elif path.endswith('.html'):
            return 'text/html'
        else:
            return super().guess_type(path)

Handler = MyHttpRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Сервер запущен на порту {PORT}")
    httpd.serve_forever()
