FROM node:16-slim

WORKDIR /app
RUN npm install express
COPY ./index.js .

CMD [ "node", "index.js" ]