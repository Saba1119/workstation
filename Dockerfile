# Use an official Ubuntu as a parent image
FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

# Set environment variables to avoid user interaction during the installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install essential packages
RUN apt-get update && \
    apt-get install -y \
        wget \
        gnupg \
        gnupg2 \
        software-properties-common \
        apt-transport-https \
        curl \
        build-essential \
        unzip \
        ca-certificates \
        lsb-release

# Install Java 1.8 and 11
RUN apt-get install -y openjdk-8-jdk openjdk-11-jdk && \
    update-alternatives --config java

# Install Git
RUN apt-get install -y git

# Install Scala 2.12
RUN curl -L -o scala.deb https://downloads.lightbend.com/scala/2.12.15/scala-2.12.15.deb && \
    dpkg -i scala.deb && \
    rm scala.deb

# Install VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/ && \
    sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' && \
    apt-get update && \
    apt-get install -y code && \
    rm -f packages.microsoft.gpg

# Install Python and pip
RUN apt-get install -y python3 python3-pip

# Install a Python package (e.g., numpy)
RUN pip3 install numpy

# Install Node.js 14.17.4 and npm 6.14.14
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@6.14.14


# Verify Node.js and npm installation
RUN node -v && npm -v

# Install React (create-react-app)
RUN npm install -g create-react-app

# Install C and C++
RUN apt-get install -y gcc g++

# Install PHP
RUN apt-get install -y php


# Install Kubernetes CLI (kubectl)
RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh    

# Install Scala Metals and Parquet Viewer extensions for VS Code
RUN wget https://open-vsx.org/api/scalameta/metals/1.23.0/file/scalameta.metals-1.23.0.vsix && \
    unzip scalameta.metals-1.23.0.vsix "extension/*" && \
    mv extension /opt/code-oss/extensions/scala-metals

RUN wget https://open-vsx.org/api/dvirtz/parquet-viewer/2.2.2/file/dvirtz.parquet-viewer-2.2.2.vsix && \
    unzip dvirtz.parquet-viewer-2.2.2.vsix "extension/*" && \
    mv extension /opt/code-oss/extensions/parquet-viewer

# Install Redis and start service
RUN apt-get install -y redis-server && \
    service redis-server start
# Install PostgreSQL (psql)
RUN apt-get install -y postgresql-client


# Clean up unnecessary packages
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

