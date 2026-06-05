FROM node:20-alpine AS base
RUN corepack enable && corepack prepare pnpm@10.11.1 --activate

FROM base AS deps
WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/backend/package.json apps/backend/package.json
# COPY apps/storefront/package.json apps/storefront/package.json

RUN pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/apps/backend/node_modules ./apps/backend/node_modules
# COPY --from=deps /app/apps/storefront/node_modules ./apps/storefront/node_modules
COPY . .

WORKDIR /app/apps/backend
RUN pnpm build

#WORKDIR /app/apps/storefront
#RUN pnpm build

FROM base AS backend
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=9000

COPY --from=builder /app/apps/backend/.medusa/server ./
RUN pnpm install --prod --no-frozen-lockfile

EXPOSE 9000
CMD ["sh", "-c", "pnpm medusa db:migrate && pnpm start"]

#FROM base AS storefront
#WORKDIR /app
#
#ENV NODE_ENV=production
#ENV PORT=8000
#ENV NEXT_TELEMETRY_DISABLED=1
#
#COPY --from=builder /app/apps/storefront ./
#
#EXPOSE 8000
#CMD ["pnpm", "start"]
