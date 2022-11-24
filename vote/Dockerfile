# https://hub.docker.com/r/softonic/node-prune
FROM softonic/node-prune AS prune

# https://hub.docker.com/_/node/
FROM node:18.10-alpine AS build
# With `NODE_ENV=production` npm install will skip devDependencies packages
ENV NODE_ENV production
ARG VERSION
ENV VERSION $VERSION
ARG WEBSITE_PORT
ENV WEBSITE_PORT $WEBSITE_PORT
ARG POSTGRES_HOST
ENV POSTGRES_HOST $POSTGRES_HOST
ARG POSTGRES_DATABASE
ENV POSTGRES_DATABASE $POSTGRES_DATABASE
ARG POSTGRES_USER
ENV POSTGRES_USER $POSTGRES_USER
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD $POSTGRES_PASSWORD
ARG POSTGRES_PORT
ENV POSTGRES_PORT $POSTGRES_PORT
WORKDIR /app
COPY --from=prune /go/bin/node-prune /usr/local/bin/
ADD . .
RUN npm install --quiet
RUN node-prune

FROM node:18.10-alpine
ENV NODE_ENV production
WORKDIR /app
COPY --from=build /app .
CMD ["node", "index.js"]