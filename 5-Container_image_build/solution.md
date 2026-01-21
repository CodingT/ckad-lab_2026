### Solution

**Step 1 – Build the image**

```bash
cd /root/app-source
podman build -t my-app:1.0 .
```

Verify the image was created:

```bash
podman images | grep my-app
```

**Step 2 – Save image as tarball**

```bash
podman save --format oci-archive -o /root/my-app.tar my-app:1.0
```

Verify the file was created:

```bash
ls -lh /root/my-app.tar
```