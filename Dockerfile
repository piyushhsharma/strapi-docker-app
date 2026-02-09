FROM node:20-alpine

# Install required build tools (for sqlite, node-gyp)
RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 1337

CMD ["npm", "run", "develop"]
