from http.server import BaseHTTPRequestHandler, HTTPServer
from http.client import HTTPConnection, HTTPSConnection, HTTPException
from urllib.parse import urlparse
import os
import json

host_name = "localhost"
server_port = 9999


def GET_request(url: str):
    parsed_url = urlparse(url)
    ConnCls = HTTPSConnection if parsed_url.scheme == "https" else HTTPConnection
    conn = ConnCls(host=parsed_url.hostname, port=parsed_url.port, timeout=1)
    conn.request("GET", "/")
    response = conn.getresponse()
    return response


class Server(BaseHTTPRequestHandler):
    def __init__(self, request, client_address, server):
        for env in ["TEMPLATE_PATH", "CONTAINER_INFO"]:
            if(env not in os.environ):
                raise Exception(f"Environment variable {env} not set")

        with open(os.environ["TEMPLATE_PATH"], "rb") as f:
            self.template = f.read()

        self.container_info = json.loads(os.environ["CONTAINER_INFO"])

        super().__init__(request, client_address, server)

    def do_GET(self):
        self.send_response(200)

        if(self.path == "/status"):
            self.send_header("Content-type", "application/json")
            self.end_headers()
            response = json.dumps(self.get_container_status())
            self.wfile.write(bytes(response, "utf-8"))
        else:
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(self.template)

    def get_container_status(self):
        statuses = []
        for container in self.container_info:
            container_status = dict(name=container["name"], url=container["url"], required=container["required"])
            if(container["required"] == "true"):
                try:
                    status_code = GET_request(container["url"]).status
                    container_status["status"] = "active" if status_code < 500 else "inactive"
                except (HTTPException, ConnectionRefusedError, OSError):
                    container_status["status"] = "inactive"
            else:
                container_status["status"] = "unchecked"
            statuses.append(container_status)
        return statuses


if __name__ == "__main__":
    web_server = HTTPServer((host_name, server_port), Server)
    print("Server started http://%s:%s" % (host_name, server_port))

    try:
        web_server.serve_forever()
    except KeyboardInterrupt:
        pass

    web_server.server_close()
    print("Server stopped.")
