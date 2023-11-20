# Deployment

1. Run `bin/create_release {patch|minor|major}` to create a new release tag in GitHub
2. Ensure that the `DOCKER_REGISTRY` variable is correctly set in `.env.development.local`
3. Run `bin/build` to build and push the Docker image to the registry
4. Login to the k8s cluster and run the deploy script `~/deploy_finance_micromanager`
5. The container should take around 2-3min to boot, compile assets and start the Rails server
