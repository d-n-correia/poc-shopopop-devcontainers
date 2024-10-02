#!/bin/bash

yarn install --frozen-lockfile --ignore-scripts --cache /tmp/cache
yarn build-tsoa
yarn build
yarn migrate:postgres --env=.env.local