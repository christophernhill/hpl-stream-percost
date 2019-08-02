#
# Docker spec file for HPL and Stream perf testing container
#

# Useful commands 

# o Building/developing
# docker build -t hpl_stream -f Dockerfile .
# docker run  -d -i -t --rm hpl_stream /bin/bash
# dcker ps -a
# docker exec -i -t inspiring_ganguly /bin/bash
# docker kill inspiring_ganguly
# docker container prune

# o Pushing to repo
# docker images
# docker tag 46cc25347710 mitrc/hpl-stream:centos-20190801
# docker push mitrc/hpl-stream:centos-20190801

# o Running
# singularity exec -e docker://mitrc/hpl-stream:centos-20190801 /bin/bash --norc --noprofile
# docker run mitrc/hpl-stream:centos-20190801

FROM centos:latest

RUN yum -y update
RUN yum -y install epel-release
RUN rpm -i https://github.com/openhpc/ohpc/releases/download/v1.3.GA/ohpc-release-1.3-1.el7.x86_64.rpm
RUN yum install -y ohpc-base-compute \
    yum install -y ohpc-base \
    yum install -y which \
    yum install -y file \
    yum install -y bzip2 \
    yum install -y help2man \
    yum install -y openssh-clients \
    yum groupinstall -y 'Development Tools' \
    yum install -y gnu8-compilers-ohpc \
    yum install -y openmpi3-gnu8-ohpc \
    yum install -y openblas-gnu8-ohpc

ENV SRCDIR /home/hpl_stream_bench

RUN ( mkdir -p ${SRCDIR}; chmod 755 ${SRCDIR} )

RUN ( cd ${SRCDIR};  curl http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz  > hpl-2.3.tar.gz; tar -xzvf hpl-2.3.tar.gz )

RUN ( cd ${SRCDIR}; mkdir stream; cd stream/; curl https://www.cs.virginia.edu/stream/FTP/Code/stream.c > stream.c )

COPY run_tests.sh ${SRCDIR}
RUN  ( cd ${SRCDIR}; chmod +x run_tests.sh )

CMD ( ${SRCDIR}/run_tests.sh )
