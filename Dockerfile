FROM registry.access.redhat.com/rhel
RUN yum repolist
RUN sed -n '/rhel-7-server-rt-rpms/,/^$/ s/enabled = 1/enabled = 0/' /etc/yum.repos.d/redhat.repo
RUN yum-config-manager --save --setopt=rhel-7-server-rt-rpms.skip_if_unavailable=true
RUN yum-config-manager --save --setopt=rhel-sap-hana-for-rhel-7-server-rpms.skip_if_unavailable=true
RUN yum -y install dnsmasq wget iptables iproute procps syslinux python-requests
RUN cp /usr/share/syslinux/menu.c32 /tftp/
RUN wget --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework
RUN chmod +x pipework
RUN mkdir /tftp
WORKDIR /tftp
RUN mkdir pxelinux.cfg
RUN wget https://raw.githubusercontent.com/ljozsa/tools/master/download_latest_pxe.py
RUN chmod a+x download_latest_pxe.py
RUN ./download_latest_pxe.py http://atomic-nightly.cloud.fedoraproject.org/composes/ > ./url
RUN sed -e '2i default menu.c32\nmenu title PXE boot menu\ntimeout 30\nlabel pxe-to-live\nmenu label RHEL Atomic Host PXE-to-Live' -e 's/<PXE_DIR>\///g' -e "s!<URL>\/!$(cat ./url)!" PXE_CONFIG > pxelinux.cfg/default
RUN cp /usr/share/syslinux/pxelinux.0 /tftp/
CMD \
    echo Setting up iptables... &&\
    iptables -t nat -A POSTROUTING -j MASQUERADE &&\
    echo Waiting for pipework to give us the eth1 interface... &&\
    /pipework --wait &&\
    myIP=$(ip addr show dev eth1 | awk -F '[ /]+' '/global/ {print $3}') &&\
    mySUBNET=$(echo $myIP | cut -d '.' -f 1,2,3) &&\
    echo Starting DHCP+TFTP server...&&\
    dnsmasq --interface=eth1 \
            --dhcp-range=$mySUBNET.<num>,$mySUBNET.<num>,255.255.255.0,1h \
            --dhcp-boot=pxelinux.cfg/default,pxeserver,$myIP \
            --pxe-service=x86PC,"Install Linux",pxelinux \
            --enable-tftp --tftp-root=/tftp/ --no-daemon
