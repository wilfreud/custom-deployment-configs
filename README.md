# Custom Deployment Configurations

This is not a project, but rather a "codebase", a collection of configuration files that you can copy and paste for your projects, instead of rewriting them every time. Basically what you need to dockerize your app and automate its deployment to a VPS, using GitHub Actions.

### Note: Mostly AI generated (but tested and approved)
    - needs to udpdated later

Include in this project:

- Docker files
- Nginx config files
- GitHub Action .yaml config files

Note that for GitHub Actions, the default deployment strategy is to publish the app image to the Docker registry, then SSH into the server before pulling the image and creating its container.
With Coolify, the SSH part changes into sending HTTP(s) requests.

PPS: Most of those files are AI generated, but still tested multiple times in production environment

NOTE: Most of the deployment processes require the configuration of repositories' secrets and variables. Automate it using [Quirgo](https://github.com/wilfreud/quirgo-cli).
