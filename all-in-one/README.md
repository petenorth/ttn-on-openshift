# Deploys The Things Network https://www.thethingsnetwork.org/docs/network/ to Openshift

The approach taken here is a quick and dirty PoC one. The Things Network is open source

https://github.com/thethingsnetwork

And there are already labs which describe how to create a private network with or without docker

https://www.thethingsnetwork.org/article/setting-up-a-private-routing-environment

and

https://www.thethingsnetwork.org/article/deploying-a-private-routing-environment-with-docker-compose

For the all in one approach we concentrate on the first lab because essentially an all in one pod mirrors a local environment in terms of default network connectivity between containers.

It is assumed the reader has access to an Openshift environment and has logged on that Openshift shift cluster using the oc command line tool.

This PoC was done using minishift and is recommended if the reader does not have access to a hosted Openshift environment.

## Deploy Redis

    oc create -f redis-imagestream.yaml
    oc create -f redis-service.yaml
    oc create -f redis-claim0-persistentvolumeclaim.yaml 
    oc create -f redis-deploymentconfig.yaml 

## Create AMQ 6.2 (MQTT Broker)

If using minishift you may need to update deployment config to 1.7-2 rather than 1.4

    oc process openshift//amq62-persistent -p MQ_USERNAME=ttn -p MQ_PASSWORD=ttn MQ_PROTOCOL=openwire,mqtt,amqp | oc create -f -

## Create ttn Docker image

    oc create -f ttn-imagestream.yaml
    cat ttn-container/Dockerfile | oc new-build --name=ttn-openshift --image-stream="ttn" -D -

## Create ttnctl Docker image

    
    oc new-app https://raw.githubusercontent.com/RHsyseng/container-rhel-examples/master/starter-arbitrary-uid/uid-ocp-template-centos7.yaml
    oc start-build starter-arbitrary-uid
    cat ttnctl-container/Dockerfile | oc new-build --name=ttnctl --image-stream="starter-arbitrary-uid:centos7" -D -

## Create config maps for TTN network components

    cd .env

    oc create configmap broker-config --from-file=broker
    oc create configmap discovery-config --from-file=discovery
    oc create configmap handler-config --from-file=handler
    oc create configmap networkserver-config --from-file=networkserver
    oc create configmap router-config --from-file=router
    oc create configmap ttnctl-cert --from-file=ttnctl-cert

NOTE: I have left a ttnctl-config/.ttnctl.yml file  which could be created as a configmap and then mounted appropriately, at the time of writing there is a bug in kubernetes which means that you can't mount subpaths.  

## Create deployment config for the all in one pod

    oc create -f allinone-deploymentconfig.yaml

## Setup DevAddr prefix on broker

    oc get pod

Find the pod name of the all in one pod

    oc rsh -c broker ttn-allinone-1-59zw0
    ttn broker register-prefix 26000000/20 --config ./.env/broker/dev.yml

## Register, Create Application and Verify using ttnctl

    ttnctl user register <username> <email address>

Obtain an access token based on these instructions

https://www.thethingsnetwork.org/docs/network/cli/quick-start.html#register-and-login

Then in ttnctl container

    ttnctl user login <access token>
    ttnctl config
    ttnctl applications add <your app id> "Hello World App"
    ttnctl applications list
    ttnctl applications register
    ttnctl devices register my-device
      INFO Using Application                        SENSITIVE DATA
      INFO Generating random DevEUI...
      INFO Generating random AppKey...
      INFO Discovering Handler...                   Handler=dev
      INFO Connecting with Handler...               Handler=localhost:1904
      INFO Registered device                        SENSITIVE DATA
    ttnctl application select
  
Then open a new  shell at command line

    oc get pod

Find the pod name of the all in one pod

    oc rsh -c ttnctl ttn-allinone-1-59zw0
    cp .ttnctl/ca.cert data_ttnctl/ 
    ttnctl user login <<access token>>
    ttnctl application select
    ttnctl subscribe

in original window

    ttnctl applications pf set decoder

    function Decoder(bytes, port) {
    var decoded = {};
    decoded.temperature = ((bytes[0] << 8) | bytes[1]) / 100.00;
    return decoded;
    }

    ttnctl devices simulate my-device 07F0 

In the second window a message should be seen.      
