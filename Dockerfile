FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

# Update system and install packages
RUN sed -ir "s/archive.ubuntu.com/tw.archive.ubuntu.com/g" /etc/apt/sources.list && \
    sed -ir "s/security.ubuntu.com/tw.archive.ubuntu.com/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -yq tmux wget vim git autoconf automake autotools-dev curl \
                        libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk \
                        build-essential bison flex texinfo gperf libtool \
                        patchutils bc zlib1g-dev device-tree-compiler pkg-config \
                        libexpat-dev libncurses-dev libncurses5-dev python3

# risc-v toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    git submodule update --init --recursive riscv-newlib riscv-glibc riscv-gdb \
        riscv-gcc riscv-dejagnu riscv-binutils
RUN cd riscv-gnu-toolchain && mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --with-arch=rv32ima && \
    make -j$(nproc) && make install

ENV PATH=$PATH:/opt/riscv/bin
RUN echo "export PATH=$PATH:/opt/riscv/bin" >> ~/.bashrc

# riscv-pk (proxy kernel)
RUN wget -q https://github.com/riscv/riscv-pk/archive/v1.0.0.tar.gz && \
    tar -xvzf v1.0.0.tar.gz && rm v1.0.0.tar.gz
RUN cd riscv-pk-1.0.0 && mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --host=riscv32-unknown-elf --with-arch=rv32ima && \
    make -j$(nproc) && make install

# Spike ISA Simulator
RUN wget -q https://github.com/riscv/riscv-isa-sim/archive/v1.0.0.tar.gz && \
    tar -xvzf v1.0.0.tar.gz && rm v1.0.0.tar.gz
RUN cd riscv-isa-sim-1.0.0 && mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --enable-histogram --with-isa=rv32ima && \
    make -j$(nproc) && make install

# Cleanup
RUN apt-get autoremove -y && apt-get autoclean && \
    rm -rf /riscv-gnu-toolchain /riscv-pk-1.0.0 /riscv-isa-sim-1.0.0 \
           /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

# Copy files
WORKDIR /root
VOLUME /root/tmp
COPY test/* /root/

# Start Up
CMD ["./startup.sh"]
