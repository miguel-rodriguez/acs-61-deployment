resource "aws_mq_broker" "activemq" {
  broker_name = "${var.resource-prefix}-activemq"

  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  host_instance_type = "mq.m4.large"
  security_groups    = ["${var.repo-security-group}","${var.solr-security-group}"]
  subnet_ids         = ["${var.private-subnet-1-id}","${var.private-subnet-2-id}"]
  deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"

 
  configuration {
    id       = "${aws_mq_configuration.configuration.id}"
    revision = "${aws_mq_configuration.configuration.latest_revision}"
  }

  user {
    username = "${var.mq-user}"
    password = "${var.mq-password}"
    groups = ["users"]
  }

  depends_on = ["aws_mq_configuration.configuration"]
}

resource "aws_mq_configuration" "configuration" {
  description    = "ActiveMQ Configuration for Alfresco"
  name           = "AlfrescoConfiguration"
  engine_type    = "ActiveMQ"
  engine_version = "5.15.0"

  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker schedulePeriodForDestinationPurge="10000" xmlns="http://activemq.apache.org/schema/core">
  <destinationPolicy>
    <policyMap>
      <policyEntries>
        <policyEntry gcInactiveDestinations="true" inactiveTimoutBeforeGC="600000" topic="&gt;">
          <pendingMessageLimitStrategy>
            <constantPendingMessageLimitStrategy limit="1000"/>
          </pendingMessageLimitStrategy>
        </policyEntry>
        <policyEntry gcInactiveDestinations="true" inactiveTimoutBeforeGC="600000" queue="&gt;"/>
      </policyEntries>
    </policyMap>
  </destinationPolicy>
  <plugins>
     <simpleAuthenticationPlugin>
         <users>
            <authenticationUser username="system" password="manager" groups="users,admins"/>
            <authenticationUser username="user" password="password" groups="users"/>
            <authenticationUser username="guest" password="password" groups="guests"/>
         </users>
     </simpleAuthenticationPlugin>
     <authorizationPlugin>
         <map>
            <authorizationMap>
               <authorizationEntries>
                   <authorizationEntry topic="Consumer.*.VirtualTopic.alfresco.repo.events.nodes>" read="users" 
                    write="users" admin="users"/>
                   <authorizationEntry topic="ActiveMQ.Advisory.>" read="guests,users" 
                   write="guests,users" admin="guests,users"/>
                   <authorizationEntry topic="VirtualTopic.alfresco.repo.events.nodes" read="guests,users" 
                    write="guests,users" admin="guests,users"/>
                  <authorizationEntry admin="users" queue="org.alfresco.transform.t-request.acs" read="users" write="users"/>
                  <authorizationEntry admin="users" queue="&gt;" read="users" write="users"/>                    
               </authorizationEntries>
            </authorizationMap>
         </map>
     </authorizationPlugin> 
  </plugins>
</broker>
  DATA
}