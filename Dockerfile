FROM hypriot/rpi-java:latest
MAINTAINER Andre Elie <aelie@inria.fr>

RUN apt-get update\
        && apt-get upgrade -y\
	&& apt-get install -y apt-utils git zip unzip python-pip python3-pip
RUN cd /opt\
        && wget http://apache.websitebeheerjd.nl/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz\
        && tar xzvf apache-maven-3.3.9-bin.tar.gz\
        && export PATH=/opt/apache-maven-3.3.9/bin:$PATH
RUN cd /opt\
        && git config --global http.sslVerify false\
        && git clone https://github.com/DIVERSIFY-project/SMART-GH.git
RUN cd /opt/SMART-GH\
	&& git checkout undertow_cached \
        && pip install plumbum\
	&& python generate_config.py --city dublin --sensors GoogleTraffic,NoiseTube,OzoneDetect --modes car,bike,walk,scooter,motorcycle \
	&& wget http://thingml.org/dist/diversify/dublin-gh.zip \
        && apt-cache show zip\ 
	&& unzip dublin-gh.zip -d dublin-gh
RUN echo $PATH\
        && export PATH=/opt/apache-maven-3.3.9/bin:$PATH\
        && echo $PATH\
        && echo $JAVA_HOME
RUN cd /opt/SMART-GH\
        && export PATH=/opt/apache-maven-3.3.9/bin:$PATH\
        && mvn clean
RUN cd /opt/SMART-GH\
        && export PATH=/opt/apache-maven-3.3.9/bin:$PATH\
        && mvn -DskipTests install
RUN cd /opt/SMART-GH/daemon-wservice \
        && export PATH=/opt/apache-maven-3.3.9/bin:$PATH\
	&& mvn package
RUN cd /opt/SMART-GH/daemon-wservice\ 
        && cp -r ../maps /tmp \
	&& cp -r ../*.properties /tmp \
	&& cp -r ../sensors-config-files/*.config /tmp \
	&& cp -r target/*.jar /tmp \
	&& cp -r target/*.war /tmp \
	&& apt-get --purge autoremove -y maven git\
	&& rm -rf /opt/SMART-GH/ \
	&& cd / \
        && echo "cd tmp; java -jar restful-graphhopper-1.0-swarm.jar" > run.sh \
	&& chmod a+x /run.sh

CMD /run.sh
