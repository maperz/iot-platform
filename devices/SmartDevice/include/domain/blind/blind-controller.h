#ifndef DM_BLIND_H_GUARD
#define DM_BLIND_H_GUARD

#include "controller.h"

enum BlindPosition {
  Top,
  Mid,
  Bot
};

class BlindController : public Controller {
public:
  BlindController(PubSubClient *client) : Controller(client) { setup(); };

  void setup();

  virtual void loop();

  virtual bool onRequest(const String &request, char *payload, size_t plength);
  virtual String getState();

  virtual String getType() { return "blind"; }
  virtual String getVersion() { return "1.0.0"; }

private:
  long _openTime;
  long _closeTime;

  void moveBlind(BlindPosition position) const;
};

#endif // DM_BLIND_H_GUARD