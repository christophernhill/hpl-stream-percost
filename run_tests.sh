#!/bin/bash

#
#  To provision a CentOS machine for docker
#  yum -y update
#  yum install -y yum-utils   device-mapper-persistent-data   lvm2
#  yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
#  yum install docker-ce docker-ce-cli containerd.io
#  systemctl start docker
#  #  docker run hello-world
#  #  docker run --rm mitrc/hpl-stream:centos-20190801
#
#

source /etc/bashrc
module load gnu8/8.3.0
module load openblas/0.3.5
module load openmpi3/3.1.4

systemctl start sshd

#
# Two modes here -
#  First with writable default SRCDIR is native "docker style"
#   i.e. docker run --rm mitrc/hpl-stream:centos-20190801
#  Second with non-writable default SRCDIR is "singularity style"
#   i.e. singularity run -e docker://mitrc/hpl-stream:centos-20190801
#
if [ -w ${SRCDIR} ]; then 
 echo "Writable SRCDIR"
else 
 echo "Non-writable SRCDIR"
 tdir=test-`uuidgen`
 mkdir $tdir
 cp -pr $SRCDIR/* $tdir
 export SRCDIR=`pwd`/$tdir
fi

cd ${SRCDIR}
cd hpl-2.3
./configure LDFLAGS='-L/opt/ohpc/pub/libs/gnu8/openblas/0.3.5/lib' CFLAGS='-march=native -mtune=native -O3'
make

cat > HPL.dat <<'EOFA'
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
10080        Ns
1            # of NBs
128          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
1            Ps
1            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOFA

taskset -c 0 ./testing/xhpl

cd ${SRCDIR}
cd stream
gcc -O3  -march=native -mtune=native stream.c -mcmodel=large -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20  -o stream_20x1800M;
taskset -c 0 ./stream_20x1800M
