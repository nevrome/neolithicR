// This recieves messages of type "startmessage" from the server.
Shiny.addCustomMessageHandler("startmessage",
  function(message) {
    alert(JSON.stringify(message));
  }
);