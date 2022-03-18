# Development

The simplest way to build this image locally, it's to use Docker Compose.
To do so, you will need to create 2 files: `CP_DB_PASSWORD.secret` and `DB_ROOT_PASSWORD.secret` (files with `.secret` extension are git-ignored).

```
echo "my_secret_password" > CP_DB_PASSWORD.secret
echo "turbo_secret_password" > DB_ROOT_PASSWORD.secret
```

Now, you simply run:

```sh
docker-compose -f docker-compose.dev.yaml up
```

The container will be accessible via http://localhost:8000 
