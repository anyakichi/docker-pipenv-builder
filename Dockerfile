ARG pyversion=latest
FROM python:${pyversion}

RUN \
  apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    gosu \
    sudo \
    wait-for-it \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install pipenv

RUN \
  useradd -ms /bin/bash builder \
  && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
RUN \
  echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "builder@pipenv" \
  && git config --global user.name "pipenv builder"

USER root
WORKDIR /home/builder

ENV \
  DEFAULT_SCRIPT=start \
  GIT_REPO="" \
  LANG=C.UTF-8 \
  PIPENV_VENV_IN_PROJECT=1

COPY buildenv/entrypoint.sh /usr/local/sbin/entrypoint
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
CMD ["/bin/bash"]
