# Nginx Forward Proxy

## Build
```bash
docker build -t congtaojiang/nginx-forward-proxy .
```

## Test

### Terminal 1
```bash
docker run -it --rm -p 8888:8888 -p 8443:8443 nginx-fwdproxy
```
or 
```
docker-compose -f docker-compose-nginx-forward-proxy.yaml up
```

### Terminal 2
```bash
# client http proxy to issue http request
curl -L -x http://localhost:8888 http://httpbin.org/get

# client http proxy to issue https request
curl -L -x http://localhost:8888 https://httpbin.org/get

# client https proxy to issue http request
curl -L --proxy-insecure -x https://localhost:8443 http://httpbin.org/get

# client https proxy to issue https request
curl -L --proxy-insecure -x https://localhost:8443 https://httpbin.org/get

```