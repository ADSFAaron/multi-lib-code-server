FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

# Install dependencies
RUN apt-get update --fix-missing && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  curl \
  apt-utils \
  ca-certificates \
  dumb-init \
  htop \
  sudo \
  git \
  bzip2 \
  libx11-6 \
  locales \
  man \
  wget \
  git \
  procps \
  graphviz libgraphviz-dev \
  vim.tiny \
  lsb-release \
  python3 \
  python3-pip \
  python3-opencv \
  build-essential \
  apache2-utils \
  tree \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# zh_TW.UTF-8/zh_TW.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=zh_TW.UTF-8

# Create project directory
RUN mkdir /projects

RUN apt-get clean

RUN df -h

RUN free -m

# Install pip library
RUN pip install --no-cache-dir -U pip && \
  pip install --no-cache-dir torch==1.13.1+cu116 torchvision==0.14.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116 && \
  pip install --no-cache-dir --no-deps torchtext==0.15.2 torchdata==0.6.1

RUN df -h

RUN pip install --no-cache-dir typing-extensions pillow idna certifi urllib3 charset-normalizer

RUN pip install --no-cache-dir tensorflow-gpu==2.10.1 keras==2.10.0 \
  pytest==7.2.2 graphviz==0.19.1 pytensor

RUN pip install --no-cache-dir plotly torchviz pandas pandas-datareader pandas-gbq \
  beautifulsoup4 requests lxml requests-oauthlib \
  scikit-learn scikit-image scipy sklearn-pandas \
  seaborn matplotlib \
  tables tornado tqdm wordcloud pip-tools pathlib networkx numpy LunarCalendar

RUN pip install --no-cache-dir opencv-contrib-python opencv-python opencv-python-headless \
  Markdown markdown-it-py MarkupSafe \
  ipykernel ipython ipython-genutils ipywidgets ipython-sql \
  imageio imageio-ffmpeg \
  virtualenv flask protobuf==3.19.6

RUN pip install --no-cache-dir yfinance zipp zict tokenizers scooby PyDrive2 huggingface-hub diskcache \
  transformers timm==0.5.4 moviepy

RUN pip install --no-cache-dir --upgrade nvitop

# Create a non-root user
RUN adduser --disabled-password --gecos '' --shell /bin/bash coder \
  && chown -R coder:coder /projects
RUN echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-coder

# Install fixuid with permission error
ENV ARCH=amd64
RUN curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
  chown root:root /usr/local/bin/fixuid && \
  chmod 4755 /usr/local/bin/fixuid && \
  mkdir -p /etc/fixuid && \
  printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

# Install code-server
WORKDIR /tmp
ARG CODE_SERVER_VERSION=latest
ENV CODE_SERVER_VERSION=${CODE_SERVER_VERSION}
# 使用 ENV 設定的版本來安裝 code-server
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${ARCH}.deb
RUN dpkg -i ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb && rm ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb
COPY ./entrypoint.sh /usr/bin/entrypoint.sh

# Cleanup to make the image smaller
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.cache /var/cache

# Switch to default user
USER coder
ENV USER=coder
ENV HOME=/home/coder
WORKDIR /projects

EXPOSE 8443
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8443", "--disable-telemetry", "."]
