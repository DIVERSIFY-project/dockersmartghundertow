FROM maven:latest
MAINTAINER Olivier Barais <barais@irisa.fr>

RUN apt-get update \
	&& apt-get upgrade -y\
	&& apt-get install -y git python-plumbum zip apt-utils\
	&& cd /opt \
	&& git clone https://github.com/DIVERSIFY-project/SMART-GH.git \
	&& cd /opt/SMART-GH/ \
	&& git checkout undertow \
	&& python generate_config.py --city dublin --sensors GoogleTraffic,NoiseTube,OzoneDetect --modes car,bike \
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
