# Forward-proxy container

The forward-proxy container is built on Alpine 3.22 and uses `tinyproxy` as an
HTTP and HTTPS proxy. When the container is deployed to a GCP VM, HTTP/S traffic
can be proxied through an IAP tunnel to the container host, and then on to any
GCP resource that the VM is permitted to reach.

A new `forward-proxy` container will be automatically built and pushed to Docker
Hub and GitHub Container repositories when the repo source is tagged.
