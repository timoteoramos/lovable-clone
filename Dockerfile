FROM node:22 AS build

ARG DEBIAN_FRONTEND=noninteractive \
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=

WORKDIR /home/node

USER node

COPY --chown=node:node ./package*.json /home/node

COPY --chown=node:node ./prisma /home/node/prisma

RUN npm install

COPY --chown=node:node ./*.json ./*.mjs ./*.ts /home/node/

COPY --chown=node:node ./src /home/node/src

RUN npm run build


FROM node:22 AS production

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /home/node

EXPOSE 3000

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]

CMD [ "/usr/local/bin/npm", "run", "start" ]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y dumb-init && \
    apt-get clean autoclean -y && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt

USER node

COPY --chown=node:node ./package*.json /home/node

COPY --chown=node:node ./prisma /home/node/prisma

RUN npm install

COPY --chown=node:node --from=build /home/node/.next /home/node/.next

COPY --chown=node:node ./public /home/node/public
