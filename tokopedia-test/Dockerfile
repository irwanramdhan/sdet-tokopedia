FROM ruby:2.6.0
LABEL maintainer="@irwanrmdhn"
RUN apt-get update && apt-get install -y --fix-missing curl unzip libnss3

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

RUN google-chrome --product-version

RUN chromedriver -v

RUN apt-get install -y -f && \
    rm -rf /var/lib/apt/lists/*

ENV BROWSER=chrome_headless
ENV CI=false
ENV TZ='Asia/Jakarta'

# Configuring the tests to run in the container
RUN mkdir /app
WORKDIR /app
RUN gem update
# Copy the test code
COPY . .
RUN chmod +x tokopedia.sh
RUN gem install bundler
RUN bundle install --quiet

ENTRYPOINT ["tokopedia.sh"]