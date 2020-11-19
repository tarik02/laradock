FROM node:12-alpine
WORKDIR /src

RUN apk add --update --no-cache python3 make docker && ln -sf python3 /usr/bin/python

ADD ./docker-web-gui/backend /src/backend
ADD ./docker-web-gui/client /src/client
ADD ./docker-web-gui/app.js /src/app.js

RUN cd /src/backend && npm install

RUN sed -i "s/http\\:\\/\\/localhost\\:3230//g" /src/client/src/utilities/request.js
RUN cd /src/client && npm install && npm run build
RUN rm -rf /src/backend/web && cp -r /src/client/build /src/backend/web

CMD ["node", "/src/app.js"]

EXPOSE 3230
