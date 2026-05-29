FROM node:16-alpine AS development

RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml .npmrc ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

FROM node:16-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml .npmrc ./

RUN pnpm install --prod --frozen-lockfile

COPY . .

COPY --from=development /usr/src/app/dist ./dist

CMD ["node", "dist/main"]
