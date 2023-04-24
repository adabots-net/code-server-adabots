FROM codercom/code-server:latest

# pre-install VSCode extensions
RUN code-server --install-extension AdaCore.Ada
RUN code-server --auth none >/tmp/code-server.log 2>&1 &

# install system prerequisites
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends make wget unzip libc6-dev libssl-dev libcrypto++-dev libncurses5 \
  && sudo apt-get clean && sudo rm -rf /var/cache/apt/* && sudo rm -rf /var/lib/apt/lists/* && sudo rm -rf /tmp/*

# clone AdaBots repo
RUN mkdir /home/coder/.ssh
RUN ssh-keyscan -t rsa github.com >> /home/coder/.ssh/known_hosts
RUN git clone -b coder --progress https://github.com/TamaMcGlinn/AdaBots_examples /home/coder/adabots

# Install Alire
RUN wget https://github.com/alire-project/alire/releases/download/v1.2.2/alr-1.2.2-bin-x86_64-linux.zip
RUN unzip alr-1.2.2-bin-x86_64-linux.zip 
RUN sudo mv bin/alr /usr/local/bin/
RUN rm LICENSE.txt
RUN alr toolchain --select gnat_native
RUN alr toolchain --select gprbuild

# Unfortunately these are missing after GNAT2021 -> alr transition
# so I've just copied them into this repository
COPY /tools/gnatls /usr/local/bin/
COPY /tools/gprbuild /usr/local/bin/
COPY /tools/gnatpp /usr/local/bin/

# Download alr bash completion script
RUN wget https://raw.githubusercontent.com/alire-project/alire/v1.2.2/scripts/alr-completion.bash -O /home/coder/alr-completion.bash
RUN echo 'source /home/coder/alr-completion.bash' >> /home/coder/.bashrc

# build AdaBots
WORKDIR /home/coder/adabots
RUN alr build

# For debugging, override starting the webserver
# ENTRYPOINT bash 
