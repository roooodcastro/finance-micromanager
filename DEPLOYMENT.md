# Deployment

1. Create release through GitHub Actions
2. Wait for GitHub actions to finish building and pushing the Docker image
3. Login to the k8s cluster and run the deploy script `~/deploy_finance_micromanager`
4. The container should take around 2-3min to boot and start the Rails server
