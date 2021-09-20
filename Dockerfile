FROM trailofbits/polytracker-llvm:latest

MAINTAINER Evan Sultanik <evan.sultanik@trailofbits.com>
MAINTAINER Carson Harmon <carson.harmon@trailofbits.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update  \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ninja-build                                     \
      python3-pip                                     \
      python3.8-dev                                   \
      libgraphviz-dev                                 \
      graphviz										  \
      libsqlite3-dev                                  \
      vim                                             \
      gdb                                             \
      sqlite3

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10
RUN python3 -m pip install pip && python3 -m pip install pytest

COPY . /polytracker
WORKDIR /polytracker
RUN pip3 install .
RUN mkdir /polytracker/build
WORKDIR /polytracker/build
RUN cmake -GNinja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_VERBOSE_MAKEFILE=TRUE -DCXX_LIB_PATH=/cxx_libs .. 
RUN ninja install


# Setting up build enviornment for targets 
ENV POLYTRACKER_CAN_RUN_NATIVELY=1
ENV CC=/polytracker/build/bin/polybuild_script
ENV CXX=/polytracker/build/bin/polybuild_script++
ENV PATH=/polytracker/build/bin:$PATH
