FROM hypriot/rpi-java:latest
MAINTAINER Andre Elie <aelie@inria.fr>

RUN apt-get update\
        && apt-get upgrade -y\
	&& apt-get install -y maven apt-utils git zip python-pip python3-pip\
	&& cd /opt
RUN git config --global http.sslVerify false\
        && git clone https://github.com/DIVERSIFY-project/SMART-GH.git
RUN cd SMART-GH\
	&& git checkout undertow_cached \
        && pip install plumbum\
	&& python generate_config.py --city dublin --sensors GoogleTraffic,NoiseTube,OzoneDetect --modes car,bike,walk,scooter,motorcycle \
	&& wget http://thingml.org/dist/diversify/dublin-gh.zip \
	&& unzip dublin-gh.zip -d dublin-gh
RUN cd SMART-GH\
        && mvn clean
RUN cd SMART-GH && mvn -DskipTests install
RUN mvn --version
RUN cd SMART-GH/daemon-wservice \
	&& mvn package
RUN cd SMARTGH && cp -r ../maps /tmp \
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
