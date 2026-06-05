#!/bin/sh
cd /server/apps/backend

echo "Running database migrations..."
pnpm medusa db:migrate

echo "Seeding database..."
pnpm seed || echo "Seeding failed, continuing..."

echo "Building Medusa backend..."
cd /server/apps/backend && pnpm build

echo "Building Next.js Storefront..."
cd /server/apps/storefront && pnpm build

echo "Starting Next.js Storefront..."
cd /server/apps/storefront && pnpm start &

echo "Starting Medusa backend server..."
cd /server/apps/backend && pnpm start
