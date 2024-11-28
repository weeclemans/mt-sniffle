```
# Build a docker image
docker build -t mt_wine_alpine_amd64 .

# Run a docker container
docker run --rm -dit -p 5900:5900 --name mt_wine_alpine_amd64  mt_wine_alpine_amd64

```

