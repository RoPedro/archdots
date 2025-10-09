FROM archlinux:latest

# Updates and installs essentials
RUN pacman -Syu --noconfirm && pacman -S --noconfirm \
  sudo \
  vim \
  git

RUN useradd -ms /bin/bash testuser && \
  echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Gets the linuxtools-term repo
COPY . /home/testuser/archdots
WORKDIR /home/testuser/archdots

# Starts bash for debugging
CMD ["bash"]
