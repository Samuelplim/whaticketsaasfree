# Build stage
FROM node:20-alpine AS build-deps
WORKDIR /usr/src/app

# Add build-time environment variables
ARG REACT_APP_BACKEND_URL
ARG REACT_APP_HOURS_CLOSE_TICKETS_AUTO

# Set environment variables for build
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
ENV REACT_APP_HOURS_CLOSE_TICKETS_AUTO=$REACT_APP_HOURS_CLOSE_TICKETS_AUTO

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Final stage
FROM node:20-alpine
WORKDIR /usr/src/app
RUN apk add --no-cache jq nano

# Copy built files and scripts
COPY --from=build-deps /usr/src/app/build ./build
COPY server.js ./
COPY add-env-vars.sh ./
RUN chmod +x add-env-vars.sh

# Runtime environment variables
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
ENV REACT_APP_HOURS_CLOSE_TICKETS_AUTO=$REACT_APP_HOURS_CLOSE_TICKETS_AUTO

RUN npm install express
EXPOSE 3250

CMD ["sh", "-c", "sh ./add-env-vars.sh && node server.js"]
