#############################################################
# Dockerfile to build Interactive Broker TWS container images
#############################################################
#FROM java:8
FROM cogniteev/oracle-java:java8

# File Author / Maintainer
MAINTAINER Andrew Pierce

# Install libs
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    gsettings-desktop-schemas \
    xvfb \
    libxrender1 \
    libxtst6 \
    x11vnc

# Download IB Connect and TWS
RUN cd /tmp && \
    wget https://github.com/ib-controller/ib-controller/releases/download/v3.0.1/IBController-3.0.1.zip && \
    unzip IBController-3.0.1.zip -d /opt/IBController && \
    wget https://download2.interactivebrokers.com/installers/tws/stable-standalone/tws-stable-standalone-linux-x64.sh && \
    chmod +x tws-stable-standalone-linux-x64.sh && \
    echo "n" | ./tws-stable-standalone-linux-x64.sh && \
    rm -rf /tmp/* && \
    mv /root/Jts/952 /opt/IBJts

# Set up Virtual Framebuffer and VNC
ADD vnc_init /etc/init.d/vnc
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ENV DISPLAY :0.0

# Set up IBConnect
RUN mkdir -p /opt/IBJts/jars/dhmyhmeut/
ADD jts.ini /opt/IBJts/jars/
ADD tws.xml /opt/IBJts/jars/dhmyhmeut/
ADD IBController.ini /opt/IBController/
ADD IBControllerStart.sh /opt/IBController/
RUN chmod +x /opt/IBController/IBControllerStart.sh

# Set your personal credentials for TWS and VNC (remote desktop)
ENV TWSUSERID fdemo
ENV TWSPASSWORD demouser
ENV VNC_PASSWORD sandwiches

# Start TWS
EXPOSE 4001 5900
CMD ["/bin/bash", "/opt/IBController/IBControllerStart.sh"]
