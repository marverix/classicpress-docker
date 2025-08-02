# Development

The simplest way to build this image locally, it's to use Docker Compose.
You will also need to have a group `press(gid=2048)` and your user is assigned to it.

Now, you simply run:

```sh
docker compose -f docker-compose.dev.yaml up
```

The container will be accessible via http://localhost:8080 
