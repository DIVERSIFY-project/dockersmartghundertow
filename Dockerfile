FROM hypriot/rpi-java:latest
MAINTAINER Olivier Barais <barais@irisa.fr>

RUN apt-get update\
        && apt-get upgrade -y\
	&& apt-get install -y maven apt-utils git zip\
	&& cd /opt
RUN git config --global http.sslVerify false\
        && git clone https://github.com/DIVERSIFY-project/SMART-GH.git
RUN cd /opt/SMART-GH/ \
	&& git checkout undertow_cached \
	&& python generate_config.py --city dublin --sensors GoogleTraffic,NoiseTube,OzoneDetect --modes car,bike,walk,scooter,motorcycle \
	&& wget http://thingml.org/dist/diversify/dublin-gh.zip \
	&& unzip dublin-gh.zip -d dublin-gh \
	&& cd /opt/SMART-GH/ \
	&& mvn clean \
	&& mvn -DskipTests install \
	&& cd daemon-wservice \
	&& mvn package \
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
