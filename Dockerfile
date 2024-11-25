# Use Node.js as base image
FROM node:20

# Install system dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    curl \
    git \
    gnupg \
    unzip \
    openjdk-17-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user first (moved up)
RUN useradd -ms /bin/bash developer

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Download and install Android SDK Command-line tools
RUN cd ${ANDROID_HOME}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools-linux-9477386_latest.zip \
    && mv cmdline-tools latest \
    && rm commandlinetools-linux-9477386_latest.zip

# Accept licenses and install Android SDK packages
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Install React Native CLI
RUN npm install -g npm@latest @react-native-community/cli

# Set up development directory
WORKDIR /home/developer

# Set ownership for developer user
RUN chown -R developer:developer /home/developer
RUN chown -R developer:developer ${ANDROID_HOME}

# Set up the working directory for the repository
USER developer
WORKDIR /home/developer/repo

# Command to keep container running
CMD ["bash"]