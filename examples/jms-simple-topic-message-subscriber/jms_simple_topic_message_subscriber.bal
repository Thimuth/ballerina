import ballerina/jms;
import ballerina/log;

// This creates a simple topic listener. This example makes use of the ActiveMQ
// Artemis broker for demonstration while it can be tried with other brokers
// that support JMS.
listener jms:TopicSubscriber subscriberEndpoint = new({
        initialContextFactory: 
        "org.apache.activemq.artemis.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616",
        acknowledgementMode: "AUTO_ACKNOWLEDGE"
    }, topicPattern = "MyTopic");

// This binds the created subscriber to the listener service.
service jmsListener on subscriberEndpoint {

    //This resource is invoked when a message is received.
    resource function onMessage(jms:TopicSubscriberCaller consumer,
    jms:Message message) {
        // Retrieve the text message.
        var messageText = message.getTextMessageContent();
        if (messageText is string) {
            log:printInfo("Message : " + messageText);
        } else {
            log:printError("Error occurred while reading message",
                err = messageText);
        }
    }
}
