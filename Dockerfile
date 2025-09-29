FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
FROM httpd:alpine
RUN rm -rf /usr/local/apache2/htdocs/*
COPY --from=build /app/build /usr/local/apache2/htdocs/