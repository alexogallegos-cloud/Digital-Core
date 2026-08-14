# =============================================================================
# frontend · SPE-ANCE-001 · Angular 20 build -> Nginx
# =============================================================================
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci || npm install
COPY . .
RUN npm run build

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Angular 20 (@angular/build:application) emite en dist/nomina-portal/browser
COPY --from=build /app/dist/nomina-portal/browser /usr/share/nginx/html
EXPOSE 80
