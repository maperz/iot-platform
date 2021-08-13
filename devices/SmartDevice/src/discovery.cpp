#include "discovery.h"
#include "logger.h"

bool foundAddress = false;

MSDNHost host;

void answerCallback(const mdns::Answer *answer) {
  if (!answer->valid || strlen(answer->name_buffer) == 0 ||
      foundAddress == true) {
    return;
  }

  // A typical PTR record matches service to a human readable name.
  // eg:
  //  service: _mqtt._tcp.local
  //  name:    Mosquitto MQTT server on twinkle.local
  if (answer->rrtype == MDNS_TYPE_PTR &&
      strstr(answer->name_buffer, SERVICE_NAME) != 0) {
    host.serviceName = answer->rdata_buffer;
  }

  // A typical SRV record matches a human readable name to port and FQDN info.
  // eg:
  //  name:    Mosquitto MQTT server on twinkle.local
  //  data:    p=0;w=0;port=1883;host=twinkle.local
  if (answer->rrtype == MDNS_TYPE_SRV &&
      host.serviceName == answer->name_buffer) {
    // This hosts entry matches the name of the host we are looking for
    // so parse data for port and hostname.
    char *port_start = strstr(answer->rdata_buffer, "port=");
    if (port_start) {
      port_start += 5;
      char *port_end = strchr(port_start, ';');
      char port[1 + port_end - port_start];
      strncpy(port, port_start, port_end - port_start);
      port[port_end - port_start] = '\0';

      if (port_end) {
        char *host_start = strstr(port_end, "host=");
        if (host_start) {
          host_start += 5;
          host.port = atoi(port);
          host.hostName = host_start;
        }
      }
    }
  }

  // A typical A record matches an FQDN to network ipv4 address.
  // eg:
  //   name:    twinkle.local
  //   address: 192.168.192.9
  if (answer->rrtype == MDNS_TYPE_A && host.hostName == answer->name_buffer) {
    host.address = answer->rdata_buffer;
  }

  if (host.address != "" && host.port > 0) {
    foundAddress = true;
    printLog(LogLevel::Info,
             "ServiceDiscovery: mqtt Broker discovered at %s:%d\n",
             host.address.c_str(), host.port);
  }
}

ServiceDiscovery::ServiceDiscovery(byte *buffer, int bufferSize)
    : mdnsClient(NULL, NULL, answerCallback, buffer, bufferSize) {}

void ServiceDiscovery::reset() {
  host.address = "";
  host.port = 0;
  host.serviceName = "";
  host.hostName = "";

  foundAddress = false;
  ticks = 0;
  mdnsClient.Clear();
}

void ServiceDiscovery::loop() { mdnsClient.loop(); }

bool ServiceDiscovery::discoveryCompleted() {
  if (foundAddress) {
    return true;
  }

  if (ticks++ % 150000 == 0) {
    sendQuery();
  }
  return false;
}

void ServiceDiscovery::sendQuery() {
  mdns::Query query;
  strncpy(query.qname_buffer, SERVICE_NAME, MAX_MDNS_NAME_LEN);
  query.qtype = MDNS_TYPE_PTR;
  query.qclass = 1; // Internet
  query.unicast_response = 0;

  mdnsClient.Clear();
  mdnsClient.AddQuery(query);
  mdnsClient.Send();
  printLog(LogLevel::Info,
           "ServiceDiscovery: mDNS discovery packet sent for '%s'\n",
           query.qname_buffer);
}

MSDNHost ServiceDiscovery::getHost() { return host; }