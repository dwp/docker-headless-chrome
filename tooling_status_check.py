from http.server import BaseHTTPRequestHandler, HTTPServer
from http.client import HTTPConnection, HTTPSConnection, HTTPException
from urllib.parse import urlparse
import os
import json
import ssl

host_name = "localhost"
server_port = 9999
base_cdp_url = "http://localhost:9222/json"


def GET_request(url: str):
    parsed_url = urlparse(url)
    conn_params = dict(host=parsed_url.hostname,
                       port=parsed_url.port, timeout=1)
    conn = HTTPSConnection(**conn_params, context=ssl._create_unverified_context()
                           ) if parsed_url.scheme == "https" else HTTPConnection(**conn_params)
    conn.request("GET", f"{parsed_url.path}?{parsed_url.query}")
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

        if self.path == "/status":
            self.send_header("Content-type", "application/json")
            self.end_headers()
            response = json.dumps(self.get_container_status())
            self.wfile.write(bytes(response, "utf-8"))
        elif self.path == "/open-tabs":
            existing_tab_info = json.loads(GET_request(
                base_cdp_url).read().decode("utf-8"))
            existing_tab_ids = [tab["id"] for tab in existing_tab_info]

            new_tab_ids = list()
            for url in map(lambda container: container["url"], self.container_info):
                tab_info = json.loads(GET_request(
                    base_cdp_url + f"/new?{url}").read().decode("utf-8"))
                new_tab_ids.append(tab_info["id"])

            GET_request(base_cdp_url + f"/activate/{new_tab_ids[0]}")

            for id in existing_tab_ids:
                GET_request(base_cdp_url + f"/close/{id}")
        else:
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(self.template)

    def get_container_status(self):
        statuses = []
        for container in self.container_info:
            container_status = dict(name=container["name"], url=container["url"],
                                    required=container["required"] == True or container["required"] == "true")
            if container_status["required"] == True:
                try:
                    status_code = GET_request(container["url"]).status
                    container_status["status"] = "active" if status_code < 500 else "inactive"
                except (HTTPException, ConnectionRefusedError, OSError) as e:
                    print(
                        f"Exception while trying to reach service {container_status['url']}", flush=True)
                    print(e, flush=True)
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
