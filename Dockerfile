FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY client/package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy client source
COPY client/src ./src
COPY client/public ./public
COPY client/*.config.js ./

# Build application
RUN npm run build

# Use nginx for serving
FROM nginx:alpine

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app from previous stage
COPY --from=0 /app/dist /usr/share/nginx/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
