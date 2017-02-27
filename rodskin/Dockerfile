FROM scratch
# mozjpeg and jpeg-archive
WORKDIR /usr/local/src/
RUN git clone https://github.com/mozilla/mozjpeg.git && \
    cd mozjpeg && \
    autoreconf -fiv && \
    ./configure --with-jpeg8 && \
    make && \
    make install
RUN git clone https://github.com/danielgtaylor/jpeg-archive.git && \
    cd jpeg-archive && \
    make && \
    make install


# install sitesync
WORKDIR /usr/local/src/
RUN git clone https://github.com/pa-de-solminihac/sitesync.git /sitesync && \
    chmod -R 777 /sitesync/tmp && \
    chmod -R 777 /sitesync/log
COPY profile.d_sitesync.sh /etc/profile.d/sitesync.sh

# composer
WORKDIR /usr/local/bin
RUN curl -s "https://getcomposer.org/installer" | php && mv composer.phar /usr/local/bin/composer

# better shell config
WORKDIR /root/

RUN git clone https://github.com/pa-de-solminihac/configuration.git && \
    echo "source /root/.bashrc_local" >> /root/.bashrc && \
    ln -s /root/configuration/bash/.bashrc_local && \
    ln -s /root/configuration/bash/.bashrc_common && \
    echo "source /root/.vimrc_common" >> /root/.vimrc && \
    ln -s /root/configuration/vim/.vimrc_common && \
    mkdir -p bin && \
    ln -s /root/configuration/bin/diffconflicts bin/
WORKDIR /home/devdocker/
RUN cp -pr /root/configuration /home/devdocker/ && \
    chown -R devdocker: configuration && \
    echo "source /home/devdocker/.bashrc_local" >> /home/devdocker/.bashrc && \
    ln -s /home/devdocker/configuration/bash/.bashrc_local && \
    ln -s /home/devdocker/configuration/bash/.bashrc_common && \
    echo "source /home/devdocker/.vimrc_common" >> /home/devdocker/.vimrc && \
    ln -s /home/devdocker/configuration/vim/.vimrc_common && \
    mkdir -p bin && \
    ln -s /home/devdocker/configuration/bin/diffconflicts bin/

# configure git
COPY gitconfig /home/devdocker/.gitconfig
