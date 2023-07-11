# Use the latest Ubuntu LTS version as the base image
FROM ubuntu:23.04
WORKDIR /CAN-GO 

# Set the author label
LABEL maintainer="Ray Bernard <ray.bernard@outlook.com>"

# Update the system and install necessary packages
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y curl sudo make git openssh-server

# Download Go package
# Remember to always check the latest version from the official Go website
RUN curl -O https://dl.google.com/go/go1.20.linux-amd64.tar.gz

# Install Go package
RUN tar -xvf go1.20.linux-amd64.tar.gz && \
    mv go /usr/local

# Set the Go environment variable
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Create a directory for your application
RUN mkdir /app

# Set the working directory in the Docker container to be /app
WORKDIR /app

# Copy the local package files to the container's workspace.
ADD . .



# Tidy up the Go module
RUN go mod tidy

ENV GOTRACEBACK=single
# Build and run the Go application
# RUN make build-integration-tests
# RUN ./build/tests/candevice.test 

# Configure and start SSH server
RUN mkdir -p /var/run/sshd
RUN echo 'root:some_password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#   PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]

# Expose the application on port 5004, 8080 and 22 for SSH
EXPOSE 5004 8080 22
