# Use Node.js 20 as base image
FROM node:20

# Install/update npm
RUN npm install -g npm@latest

# Install necessary system dependencies
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
    bash \
    git \
    openjdk-17-jdk-headless \
    unzip \
    wget \
    && rm -rf /var/cache/apk/*

# Setup environment variables
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Download and install Android SDK Command-line tools
# commandlinetools-linux-11076708_latest is the latest version at the time this Dockerfile was created
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools
RUN cd ${ANDROID_HOME}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip commandlinetools-linux-11076708_latest.zip \
    && mv cmdline-tools latest \
    && rm commandlinetools-linux-11076708_latest.zip

# Update Android SDK Command-line tools
RUN yes | sdkmanager --update

# Accept licenses and install Android SDK packages
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0"

# Install React Native
RUN npm install -g @react-native-community/cli@latest

# Create a non-root user
RUN useradd -ms /bin/bash developer

# Set ownership for developer user
RUN chown -R developer:developer /home/developer
RUN chown -R developer:developer ${ANDROID_HOME}

# Switch to developer user
USER developer
WORKDIR /home/developer/repo

# Expose ports
EXPOSE 5555
EXPOSE 8081

# Command to keep container running
CMD ["bash"]