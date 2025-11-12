# Multi-stage build pentru optimizare
FROM node:18-alpine as build

WORKDIR /app

# Copiază package files
COPY package*.json ./

# Instalează dependențele
RUN npm ci --legacy-peer-deps

# Copiază sursa
COPY . .

# Build pentru producție
RUN npm run build

# Stage 2: Servire cu nginx
FROM nginx:alpine

# Copiază build-ul
COPY --from=build /app/build /usr/share/nginx/html

# Copiază configurația nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
