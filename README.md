# Custom Deployment Configurations

This is not a project, but rather a "codebase", a collection of configuration files that you can copy-paste for your projects, instead of rewriting them everytime. Basically what you need to dockerize your app and automate its deployment with GitHub Actions.

Frameworks:

- React
- NextJS
- ExpressJS
- NestJS

Include in this project:

- Dockerfile files
- Nginx config files
- GitHub Action .yaml config files

Note that for GitHub Actions, the default deployment strategy is to publish the app image to the Docker registry, then SSH into the server before pulling the image and creating it's container

PS: The default package manager is pnpm, but there are additional comments for yarn

PPS: Most of those files are AI generated, but still tested multiple times in productio environment (honestly)

NOTE: Most of the deployment processes require the configuration of repositories' secrets and variables. Checkout my NPM packaque [Quirgo](https://github.com/wilfreud/quirgo-cli) to see how to make it easy.
